"""Runoff spatial pipe audio, driven only by the client's map state file."""
from pathlib import Path
import argparse,ctypes,json,math,sys,threading,time,wave
HERE=Path(sys.executable if getattr(sys,'frozen',False) else __file__).resolve().parent
import numpy as np
import sounddevice as sd
SOURCES=[(-2256,-1226,340.5),(-2256,-858,340.5),(388,-1820,112),(375.717,-362.266,643.628),(438.955,-361.556,317.095),(476.271,-402.222,116.708)]
def spatial(source,eye,yaw):
 if source<0:return 0.0,0.0
 x,y,z=SOURCES[source];dx=x-eye[0];dy=y-eye[1];dz=z-eye[2]
 radius=1500.0 if source<2 else 600.0
 gain=max(0.0,1.0-math.sqrt(dx*dx+dy*dy+dz*dz)/radius)**2
 flat=math.hypot(dx,dy);angle=math.radians(yaw)
 pan=0.0 if flat<1.0 else max(-1.0,min(1.0,(dx*math.sin(angle)-dy*math.cos(angle))/flat))
 return gain,pan
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--pid',type=int,required=True);ap.add_argument('--log-dir',type=Path,required=True);args=ap.parse_args()
 k=ctypes.WinDLL('kernel32',use_last_error=True)
 k.OpenProcess.argtypes=[ctypes.c_ulong,ctypes.c_bool,ctypes.c_ulong];k.OpenProcess.restype=ctypes.c_void_p
 k.WaitForSingleObject.argtypes=[ctypes.c_void_p,ctypes.c_ulong];k.CloseHandle.argtypes=[ctypes.c_void_p]
 handle=k.OpenProcess(0x100000,False,args.pid)
 if not handle:return
 with wave.open(str(HERE/'runoff_emit_tubewater_loop_2ch_v2_01_lp.wav'),'rb') as f:
  sr=f.getframerate();channels=f.getnchannels();assert f.getsampwidth()==2
  pcm=np.frombuffer(f.readframes(f.getnframes()),dtype='<i2').astype(np.float32)/32768.0
  pcm=pcm.reshape(-1,channels).mean(axis=1)
 n=min(220,len(pcm)//2);pcm[:n]*=np.linspace(0,1,n);pcm[-n:]*=np.linspace(1,0,n)
 snapshot=args.log_dir.parent/'save_data/TF1.Runoff/pipe_audio_state.json'
 state={'target':(0.0,0.0),'last':0.0};stop=threading.Event()
 def reader():
  last_snapshot=None
  while not stop.wait(.04):
   try:
    stamp=snapshot.stat()
    if stamp.st_mtime_ns==last_snapshot or time.time()-stamp.st_mtime>=1.2:continue
    data=json.loads(snapshot.read_text());source=int(data['source']);eye=tuple(float(data[key]) for key in ['x','y','z']);yaw=float(data['yaw'])
    if data['map']=='mp_tf1_runoff' and -1<=source<len(SOURCES) and all(math.isfinite(v) for v in (*eye,yaw)):
     state.update(target=spatial(source,eye,yaw),last=time.monotonic());last_snapshot=stamp.st_mtime_ns
   except (OSError,ValueError,KeyError,TypeError):pass
 threading.Thread(target=reader,daemon=True).start()
 cursor=0;gain=0.0;pan=0.0
 def callback(outdata,frames,timing,flags):
  nonlocal cursor,gain,pan
  target_gain,target_pan=state['target'] if time.monotonic()-state['last']<1.2 else (0.0,0.0)
  alpha=1-math.exp(-frames/sr/.12);next_gain=gain+alpha*(target_gain-gain);next_pan=pan+alpha*(target_pan-pan)
  gains=np.linspace(gain,next_gain,frames,dtype=np.float32);pans=np.linspace(pan,next_pan,frames,dtype=np.float32)
  mono=pcm[(np.arange(frames)+cursor)%len(pcm)]*gains*.4
  outdata[:,0]=mono*np.sqrt((1-pans)*.5);outdata[:,1]=mono*np.sqrt((1+pans)*.5)
  cursor=(cursor+frames)%len(pcm);gain=next_gain;pan=next_pan
 try:
  with sd.OutputStream(samplerate=sr,channels=2,dtype='float32',blocksize=1024,callback=callback):
   while k.WaitForSingleObject(handle,0)==258:time.sleep(.5)
 finally:stop.set();k.CloseHandle(handle)
if __name__=='__main__':main()
