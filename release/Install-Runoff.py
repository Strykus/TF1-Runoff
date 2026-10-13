"""Install the single TF1.Runoff mod into existing or new Northstar profiles."""
import argparse, base64, datetime, hashlib, json, os, shutil, sys
from pathlib import Path

def digest(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        for data in iter(lambda:f.read(1<<20),b''):h.update(data)
    return h.hexdigest()

def inside(root,name):
    path=(root/name).resolve()
    if not path.is_relative_to(root.resolve()):raise RuntimeError('Unsafe path: '+name)
    return path

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--game',type=Path,required=True)
    parser.add_argument('--profiles',nargs='+',default=['R2Northstar'])
    parser.add_argument('--base-profile',default='R2Northstar')
    parser.add_argument('--verify-only',action='store_true')
    args=parser.parse_args()
    package=Path(sys.executable if getattr(sys,'frozen',False) else __file__).resolve().parent
    source=package/'mods/TF1.Runoff'
    release=json.loads((package/'files.json').read_text())
    patch=json.loads((source/'northstar-patches.json').read_text())
    merged=release['merged_mods']
    base=inside(args.game,args.base_profile)
    stocks=['Northstar.Client','Northstar.Custom','Northstar.CustomServers']
    for name in stocks:
        meta=json.loads((base/'mods'/name/'mod.json').read_text(encoding='utf-8-sig'))
        if meta['Version']!='1.31.13':raise RuntimeError('This package requires Northstar mods 1.31.13')
    if not (base/'Northstar.dll').is_file():raise RuntimeError('Northstar.dll missing from base profile')
    rebuilt=[]
    for row in patch['files']:
        old=inside(base/'mods',row['source']).read_bytes()
        old=old.replace(b'\r\n',b'\n').replace(b'\r',b'\n')
        if hashlib.sha256(old).hexdigest()!=row['source_normalized_sha256']:
            raise RuntimeError('Unsupported or modified Northstar source: '+row['source'])
        data=b''.join(old[op[1]:op[1]+op[2]] if op[0]=='copy' else base64.b64decode(op[1],validate=True) for op in row['ops'])
        if hashlib.sha256(data).hexdigest()!=row['sha256']:raise RuntimeError('Patch validation failed')
        rebuilt.append((row['target'],data))
    for row in release['files']:
        path=inside(package,row['path'])
        if path.stat().st_size!=row['bytes'] or digest(path)!=row['sha256']:
            raise RuntimeError('Package integrity failure: '+row['path'])
    stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    profiles=[]
    for name in args.profiles:
        if not name or Path(name).name!=name or name in ('.','..'):
            parser.error('Profile must be a directory name')
        profile=inside(args.game,name)
        if any((profile/'mods'/s).exists() for s in stocks) and not all((profile/'mods'/s).is_dir() for s in stocks):
            raise RuntimeError('Incomplete Northstar profile: '+name)
        profiles.append((name,profile))
    print('Package verified; profiles:',', '.join(args.profiles))
    if args.verify_only:return
    first_installed={}
    asset_hashes={row['path'].removeprefix('mods/TF1.Runoff/'):row['sha256'] for row in release['files'] if row['path'].startswith('mods/TF1.Runoff/')}
    immutable={'.rpak','.starpak','.vpk','.bsp','.stbsp','.nm','.ain','.wav','.pcf'}
    for name,profile in profiles:
        profile.mkdir(parents=True,exist_ok=True)
        for stock in stocks:
            target=profile/'mods'/stock
            if not target.exists():shutil.copytree(base/'mods'/stock,target)
        if not (profile/'Northstar.dll').exists():shutil.copy2(base/'Northstar.dll',profile/'Northstar.dll')
        target=profile/'mods/TF1.Runoff'
        backup=None
        if target.exists():
            backup=profile/'runoff-backups'/stamp/'mods/TF1.Runoff'
            backup.parent.mkdir(parents=True,exist_ok=True)
            # Moving only the existing mod folder within the verified profile.
            if not target.resolve().is_relative_to(profile.resolve()):raise RuntimeError('External mod junction is not supported')
            target.rename(backup)
        reuse_roots=[profile/'mods'/old for old in merged if old!='TF1.Runoff']
        if backup is not None:reuse_roots.append(backup)
        target.mkdir(parents=True)
        for path in sorted(source.rglob('*')):
            if not path.is_file():continue
            rel=path.relative_to(source).as_posix();out=inside(target,rel);out.parent.mkdir(parents=True,exist_ok=True)
            candidate=first_installed.get(rel) if path.suffix in immutable else None
            if candidate is None and path.suffix in immutable:
                for old_root in reuse_roots:
                    old_file=old_root/rel
                    if old_file.is_file() and old_file.stat().st_size==path.stat().st_size and digest(old_file)==asset_hashes[rel]:
                        candidate=old_file;break
            if candidate is not None or path.suffix in immutable:
                try:os.link(candidate or path,out)
                except OSError:shutil.copy2(path,out)
            else:shutil.copy2(path,out)
            first_installed.setdefault(rel,out)
        for relative,data in rebuilt:
            out=inside(target,relative);out.parent.mkdir(parents=True,exist_ok=True);out.write_bytes(data)
        cfg=target/'paks/rpak.json';data=json.loads(cfg.read_text())
        for pak,value in data.get('Postload',{}).items():
            if value.startswith('./R2Northstar'):
                data['Postload'][pak]=value.replace('./R2Northstar','./'+name,1)
        cfg.write_text(json.dumps(data,indent=2)+'\n')
        enabled_path=profile/'enabledmods.json'
        enabled=json.loads(enabled_path.read_text(encoding='utf-8-sig')) if enabled_path.exists() else {'Version':1}
        if enabled_path.exists():
            b=profile/'runoff-backups'/stamp/'enabledmods.json';b.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(enabled_path,b)
        for old_name in merged:
            if old_name in enabled and isinstance(enabled[old_name],dict):
                for version in enabled[old_name]:enabled[old_name][version]=False
        enabled['TF1.Runoff']={release['version']:True}
        for stock in stocks:enabled[stock]={'1.31.13':True}
        enabled_path.write_text(json.dumps(enabled,indent=2)+'\n')
        shutil.copy2(package/'Start-Runoff.ps1',profile/'Start-Runoff.ps1')
        launch_client='@echo off\r\npowershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-Runoff.ps1" -GameDirectory "%~dp0.." -Profile "'+name+'"\r\n'
        launch_server=launch_client.rstrip()+' -Server\r\n'
        (profile/'Start-RunoffClient.cmd').write_bytes(launch_client.encode('ascii'))
        (profile/'Start-RunoffServer.cmd').write_bytes(launch_server.encode('ascii'))
        print('Installed one TF1.Runoff mod in',profile)
    print('Restart the client and server. Original separate map mods were disabled and preserved.')

if __name__=='__main__':main()
