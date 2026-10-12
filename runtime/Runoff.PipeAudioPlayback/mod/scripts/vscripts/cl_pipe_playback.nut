global function RunoffPipePlayback_ClientInit
struct{bool stateRunning=false} file
void function RunoffPipePlayback_ClientInit()
{
 if(GetMapName()!="mp_tf1_runoff"||file.stateRunning)return
 file.stateRunning=true
 thread RunoffPipePlayback_State()
}
void function RunoffPipePlayback_State()
{
 array<vector> positions=[< -2256,-1226,340.5>,< -2256,-858,340.5>,<388,-1820,112>,<375.717,-362.266,643.628>,<438.955,-361.556,317.095>,<476.271,-402.222,116.708>]
 while(true)
 {
  entity player=GetLocalClientPlayer()
  int nearest=-1
  float bestGain=0.0
  vector eye=<0,0,0>
  float yaw=0.0
  if(IsValid(player)&&IsAlive(player)&&GetGameState()==eGameState.Playing)
  {
   eye=player.EyePosition()
   yaw=player.EyeAngles().y
   foreach(int i,vector pos in positions)
   {
    float radius=i<2?1500.0:600.0
    float distance=Distance(eye,pos)
    if(distance<radius&&(i>=3||RunoffTubeAudio_IsPumpRunning()))
    {
     float gain=1.0-distance/radius
     gain= gain*gain
     if(gain>bestGain){bestGain=gain;nearest=i;}
    }
   }
  }
  NSSaveJSONFile("pipe_audio_state.json",{map="mp_tf1_runoff",source=nearest,x=eye.x,y=eye.y,z=eye.z,yaw=yaw})
  wait 0.1
 }
}
