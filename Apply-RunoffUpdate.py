"""Rebuild Runoff 0.3.1 from the 0.3.0 archives and the user's own assets.

Python 3.11+; standard library only. No debugger or collision editor is installed.
"""
import argparse,hashlib,json,shutil,tempfile,zipfile
from pathlib import Path

def sha(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--update',type=Path,default=Path('Runoff-0.3.1-update.zip'))
    ap.add_argument('--archives',type=Path,required=True,help='Folder with all three original 0.3.0 ZIPs')
    ap.add_argument('--tf1-assets',type=Path,action='append',required=True,help='Extracted Titanfall 1 asset root; repeat for additional roots')
    ap.add_argument('--game',type=Path,required=True,help='Installed Titanfall 2 folder')
    ap.add_argument('--northstar-profile',default='R2Northstar')
    ap.add_argument('--profile',default='RunoffUpdated')
    ap.add_argument('--verify-only',action='store_true')
    args=ap.parse_args()
    if not args.profile or Path(args.profile).name!=args.profile:ap.error('Profile must be a single folder name')
    with zipfile.ZipFile(args.update) as update, tempfile.TemporaryDirectory(prefix='runoff-update-') as tmp:
        work=Path(tmp);manifest=json.loads(update.read('manifest.json'));archives={}
        for base in manifest['baseline']:
            path=args.archives/base['name']
            if sha(path)!=base['sha256']:raise RuntimeError('Wrong baseline archive: '+base['name'])
            archives[base['name']]=zipfile.ZipFile(path)
        assets={}
        for root in args.tf1_assets:
            for file in root.rglob('*'):
                if file.is_file():assets.setdefault(file.relative_to(root).as_posix().lower(),file)
        destination=args.game/args.profile
        if not args.verify_only and destination.exists():raise RuntimeError('Preserving existing profile; choose a new --profile name')
        output=work/'profile';(output/'mods').mkdir(parents=True)
        for number,row in enumerate(manifest['files']):
            relative=Path(row['target'])
            if relative.is_absolute() or '..' in relative.parts:raise RuntimeError('Invalid update path')
            target=work/'verify.bin' if args.verify_only else output/'mods'/relative
            target.parent.mkdir(parents=True,exist_ok=True)
            base=row.get('base');old=None
            if base:
                if 'archive' in base:
                    old=work/'base.bin'
                    with archives[base['archive']].open(base['path']) as src,old.open('wb') as dst:shutil.copyfileobj(src,dst,1024*1024)
                elif 'tf1' in base:
                    old=assets.get(base['tf1'].lower())
                    if old is None:raise RuntimeError('Missing extracted TF1 asset: '+base['tf1'])
                else:old=args.game/args.northstar_profile/base['northstar']
                if sha(old)!=base['sha256']:raise RuntimeError('Wrong source bytes for '+row['target'])
            if row['kind']=='copy':shutil.copyfile(old,target)
            elif row['kind']=='file':
                with update.open(row['payload']) as src,target.open('wb') as dst:shutil.copyfileobj(src,dst,1024*1024)
            else:
                with old.open('rb') as src,update.open(row['payload']) as literal,target.open('wb') as dst:
                    for kind,offset,size in row['ops']:
                        stream=src if kind=='b' else literal
                        if stream.tell()!=offset:stream.seek(offset)
                        data=stream.read(size)
                        if len(data)!=size:raise RuntimeError('Truncated patch')
                        dst.write(data)
            if target.stat().st_size!=row['size'] or sha(target)!=row['sha256']:raise RuntimeError('Reconstruction failed: '+row['target'])
            if args.verify_only:target.unlink()
            if number%100==0:print(f'Verified {number+1}/{len(manifest["files"])} files',flush=True)
        if not args.verify_only:
            # The baseline World/Models archives are patch inputs only. Current
            # native texture packs are already reconstructed by the manifest.
            for config in (output/'mods').glob('*/paks/rpak.json'):
                config.write_text(config.read_text().replace('TF1MapLab',args.profile),encoding='utf-8')
            stock=args.game/args.northstar_profile
            for name in ['Northstar.Client','Northstar.Custom','Northstar.CustomServers']:
                shutil.copytree(stock/'mods'/name,output/'mods'/name)
            dll=stock/'Northstar.dll'
            if dll.exists():shutil.copy2(dll,output/'Northstar.dll')
            enabled={p.name:True for p in (output/'mods').iterdir() if p.is_dir() and (p/'mod.json').exists()}
            (output/'enabledmods.json').write_text(json.dumps(enabled,indent=2))
            shutil.copytree(output,destination)
            helper=destination/'mods/audio-helper';(helper/'runoff-playback').mkdir(exist_ok=True)
            print('Installed new profile:',destination)
        for archive in archives.values():archive.close()
        print('PASS: every reconstructed file matches the packaged SHA-256.')

if __name__=='__main__':main()
