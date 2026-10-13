"""Rebuild clean Runoff client/server profiles from the 0.3.0 archives and the user's own assets.

Python 3.11+; standard library only. No debugger or collision editor is installed.
"""
import argparse,hashlib,json,shutil,tempfile,zipfile,subprocess
from pathlib import Path

def sha(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--update',type=Path,default=Path('Runoff-0.3.2-update.zip'))
    ap.add_argument('--archives',type=Path,required=True,help='Folder with all three original 0.3.0 ZIPs')
    ap.add_argument('--tf1-assets',type=Path,action='append',required=True,help='Extracted Titanfall 1 asset root; repeat for additional roots')
    ap.add_argument('--game',type=Path,required=True,help='Installed Titanfall 2 folder')
    ap.add_argument('--northstar-profile',default='R2Northstar')
    ap.add_argument('--client-profile',default='RunoffClient')
    ap.add_argument('--server-profile',default='RunoffServer')
    ap.add_argument('--verify-only',action='store_true')
    args=ap.parse_args()
    for name in [args.client_profile,args.server_profile]:
        if not name or Path(name).name!=name:ap.error('Profile must be a single folder name')
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
        if not args.verify_only and any((args.game/name).exists() for name in [args.client_profile,args.server_profile]):raise RuntimeError('Preserving existing profiles; choose new client/server names')
        output=work/'profile';(output/'mods').mkdir(parents=True)
        for number,row in enumerate(manifest['files']):
            relative=Path(row['target'])
            if relative.is_absolute() or '..' in relative.parts:raise RuntimeError('Invalid update path')
            target=work/'verify.bin' if args.verify_only else (output/relative if row['target'].startswith('audio-helper/') else output/'mods'/relative)
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
            installer=Path(__file__).with_name('Install-RunoffClean.ps1')
            if not installer.exists():raise RuntimeError('Download Install-RunoffClean.ps1 beside this script')
            shutil.copy2(installer,output/installer.name)
            subprocess.run(['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',str(output/installer.name),' -GameDirectory'.strip(),str(args.game.resolve()),'-NorthstarProfile',args.northstar_profile,'-ClientProfile',args.client_profile,'-ServerProfile',args.server_profile],check=True)
        for archive in archives.values():archive.close()
        print('PASS: every reconstructed file matches the packaged SHA-256.')

if __name__=='__main__':main()
