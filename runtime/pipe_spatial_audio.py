"""Private Runoff pipe loop, driven by a quiet client state file; no game memory access."""
from pathlib import Path
import sys,time,json,math,wave,argparse,threading,ctypes,re
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE/'audio-runtime'))
import numpy as np
SOURCES=[(-2256,-1226,340.5),(-2256,-858,340.5),(388,-1820,112),(375.717,-362.266,643.628),(438.955,-361.556,317.095),(476.271,-402.222,116.708)]
PIPE_VOLUME = 0.4
def spatial(source,eye,yaw):
 if source<0:return 0.0,0.0,0.0
 x,y,z=SOURCES[source];dx=x-eye[0];dy=y-eye[1];dz=z-eye[2]
 distance=math.sqrt(dx*dx+dy*dy+dz*dz)
 radius=1500.0 if source<2 else 600.0
 gain=max(0.0,1.0-distance/radius)**2
 flat=math.hypot(dx,dy);angle=math.radians(yaw)
 pan=0.0 if flat<1.0 else max(-1.0,min(1.0,(dx*math.sin(angle)-dy*math.cos(angle))/flat))
 return gain,pan,distance

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--pid',type=int);ap.add_argument('--log-dir');ap.add_argument('--server-log-dir');ap.add_argument('--self-test',action='store_true');args=ap.parse_args()
 if args.self_test:
  for source,radius in [(0,1500),(2,600),(3,600)]:
   p=SOURCES[source]
   gains=[spatial(source,(p[0]+d,p[1],p[2]),0)[0] for d in [0,radius*.25,radius*.5,radius*.8,radius]]
   assert np.allclose(gains,[1,.5625,.25,.04,0])
   assert all(a>=b for a,b in zip(gains,gains[1:]))
  assert spatial(0,(-2256,-1326,340.5),0)[1]<0
  assert spatial(0,(-2256,-1126,340.5),0)[1]>0
  print('PASS: radii, continuous distance falloff, stereo direction and zero at cutoff');return
 import sounddevice as sd
 k=ctypes.WinDLL('kernel32',use_last_error=True)
 k.OpenProcess.argtypes=[ctypes.c_ulong,ctypes.c_bool,ctypes.c_ulong];k.OpenProcess.restype=ctypes.c_void_p
 k.WaitForSingleObject.argtypes=[ctypes.c_void_p,ctypes.c_ulong];k.CloseHandle.argtypes=[ctypes.c_void_p]
 handle=k.OpenProcess(0x100000,False,args.pid)
 if not handle:raise RuntimeError('Test client is not running')
 source=HERE/'restored/runoff_emit_tubewater_loop_2ch_v2_01_lp.wav'
 with wave.open(str(source),'rb') as f:
  sr=f.getframerate();channels=f.getnchannels();pcm=np.frombuffer(f.readframes(f.getnframes()),dtype='<i2').astype(np.float32).reshape(-1,channels).mean(axis=1)/32768.0
 # Smooth the source loop boundary; retain the original PCM file untouched.
 n=min(220,len(pcm)//2);pcm[:n]*=np.linspace(0,1,n);pcm[-n:]*=np.linspace(1,0,n)
 status=HERE/'runoff-playback/spatial-helper-status.json'
 state={'target':(0.0,0.0),'last':0.0,'source':-1,'distance':0.0,'line':'','probeUntil':0.0}
 stop=threading.Event();started=time.time();pattern=re.compile(r'RUNOFF_PIPE_AUDIO_STATE\s+(-?\d+)\s+([-\d.eE]+)\s+([-\d.eE]+)\s+([-\d.eE]+)\s+([-\d.eE]+)')
 def reader():
  streams={};paths={};latest_cache={};scan_at={}
  snapshot=Path(args.log_dir).parent/'save_data/Runoff.PipeAudioPlayback/pipe_audio_state.json'
  last_snapshot=None
  try:
   while not stop.is_set():
    try:
     stamp=snapshot.stat()
     if stamp.st_mtime_ns!=last_snapshot and time.time()-stamp.st_mtime<1.2:
      data=json.loads(snapshot.read_text())
      if data['map']=='mp_tf1_runoff':
       source=int(data['source']);eye=tuple(float(data[k]) for k in ['x','y','z']);yaw=float(data['yaw'])
       if -1<=source<len(SOURCES) and all(math.isfinite(v) for v in (*eye,yaw)):
        gain,pan,distance=spatial(source,eye,yaw)
        state.update(target=(gain,pan),last=time.monotonic(),source=source,distance=distance,line='quiet state file')
        last_snapshot=stamp.st_mtime_ns
    except (OSError,ValueError,KeyError,TypeError):
     pass
    for kind,logdir in [('client',args.log_dir),('server',args.server_log_dir)]:
     if not logdir:continue
     now=time.monotonic()
     if now>=scan_at.get(kind,0.0):
      files=list(Path(logdir).glob('nslog*.txt'))
      latest_cache[kind]=max(files,key=lambda p:p.stat().st_mtime) if files else None
      scan_at[kind]=now+1.0
     latest=latest_cache.get(kind)
     if latest is not None and latest!=paths.get(kind) and (kind=='server' or latest.stat().st_mtime>=started-4):
      if kind in streams:streams[kind].close()
      f=latest.open('r',encoding='utf-8',errors='replace')
      if kind=='server':f.seek(0,2)
      streams[kind]=f;paths[kind]=latest
     f=streams.get(kind)
     if not f:continue
     for line in f:
      if kind=='server':
       if 'PIPE_AUDIO_LAB_MANUAL_PIPE' in line:state['probeUntil']=time.monotonic()+5.0
       continue
      m=pattern.search(line)
      if not m:continue
      source=int(m[1]);eye=tuple(float(m[i]) for i in [2,3,4]);yaw=float(m[5])
      gain,pan,distance=spatial(source,eye,yaw)
      state.update(target=(gain,pan),last=time.monotonic(),source=source,distance=distance,line=line.strip())
    time.sleep(.04)
  finally:
   for f in streams.values():f.close()
 threading.Thread(target=reader,daemon=True).start()
 cursor=0;gain=0.0;pan=0.0
 def callback(outdata,frames,timing,flags):
  nonlocal cursor,gain,pan
  target_gain,target_pan=state['target'] if time.monotonic()-state['last']<1.2 else (0.0,0.0)
  if time.monotonic()<state['probeUntil']:target_gain,target_pan=1.0,0.0
  alpha=1-math.exp(-frames/sr/.12)
  next_gain=gain+alpha*(target_gain-gain);next_pan=pan+alpha*(target_pan-pan)
  gains=np.linspace(gain,next_gain,frames,dtype=np.float32)
  pans=np.linspace(pan,next_pan,frames,dtype=np.float32)
  mono=pcm[(np.arange(frames)+cursor)%len(pcm)]*gains*PIPE_VOLUME
  outdata[:,0]=mono*np.sqrt((1-pans)*.5)
  outdata[:,1]=mono*np.sqrt((1+pans)*.5)
  cursor=(cursor+frames)%len(pcm);gain=next_gain;pan=next_pan
 try:
  device=sd.query_devices(kind='output')
  with sd.OutputStream(samplerate=sr,channels=2,dtype='float32',blocksize=1024,callback=callback):
   while k.WaitForSingleObject(handle,0)==258:
    status.write_text(json.dumps({'clientPID':args.pid,'running':True,'pipeVolume':PIPE_VOLUME,'device':device['name'],'source':state['source'],'distance':state['distance'],'targetGain':state['target'][0],'currentGain':gain,'pan':pan,'freshState':time.monotonic()-state['last']<1.2,'stateLine':state['line']},indent=2))
    time.sleep(.5)
 finally:
  stop.set();k.CloseHandle(handle)
  status.write_text(json.dumps({'clientPID':args.pid,'running':False},indent=2))
if __name__=='__main__':main()
