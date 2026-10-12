global function RunoffTubeEffects_Init
global function RunoffTubeAudio_IsPumpRunning
struct
{
 array<int> pumpHandles
 bool pumpsRunning = false
 array<bool> audioNearby=[false,false,false,false,false,false]
 bool pumpStarted = false
 bool centralAudioStarted = false
 bool centralStarted = false
 array<int> centralHandles
} file
void function RunoffTubeEffects_Init()
{
 if ( GetMapName() != "mp_tf1_runoff" ) return
 SetConVarFloat("ns_print_played_sounds",0.0)
 foreach ( asset model in [ $"models/fx/runoff_glass_trash_pc1.mdl", $"models/fx/runoff_glass_trash_pc2.mdl", $"models/fx/runoff_glass_trash_pc3.mdl", $"models/fx/runoff_tube_water_1.mdl", $"models/fx/runoff_tube_water_1_slow.mdl" ] ) PrecacheModel( model )
 foreach ( asset name in [ $"r1t_trash_tube_fast_hld_alt", $"r1t_trash_tube_fast_hld", $"r1t_trash_tube_slow_hld", $"r1t_trash_tube_sml_fast_hld", $"r1t_trash_tube_sml_slow_hld" ] )
  PrecacheParticleSystem( name )
 AddCallback_EntitiesDidLoad( RunoffTubeEffects_Loaded )
 thread RunoffTubeEffects_EnsureCentral()
 thread RunoffTubeEffects_EnsurePump()
 // Automatic audio is owned by Runoff.PipeAudioPlayback.
}
void function RunoffTubeEffects_Loaded()
{
 RunoffTubeEffects_StartCentral()
 thread RunoffTubeEffects_PumpCycle()
}
void function RunoffTubeEffects_PumpCycle()
{
 if(file.pumpStarted)return
 file.pumpStarted=true
 while(!IsValid(GetLocalClientPlayer()))wait 0.1

 array<vector> positions = [ < -2256,-1226,340.5 >, < -2256,-858,340.5 >, <420,-1820,170>, <356,-1820,18> ]
 array<vector> angles = [ <0,0,0>, <0,0,0>, <0,0,180>, <0,0,0> ]
 bool running = true
 array<asset> fast = [ $"r1t_trash_tube_fast_hld", $"r1t_trash_tube_sml_fast_hld" ]
 array<asset> slow = [ $"r1t_trash_tube_slow_hld", $"r1t_trash_tube_sml_slow_hld" ]
 while ( true )
 {
  foreach ( int handle in file.pumpHandles ) EffectStop( handle, false, true )
  file.pumpHandles.clear()
  foreach ( int i, vector pos in positions )
  {
   int kind = i < 2 ? 0 : 1
   int fx = GetParticleSystemIndex( running ? fast[kind] : slow[kind] )
   file.pumpHandles.append( StartParticleEffectInWorldWithHandle( fx, pos, angles[i] ) )
  }
  RunoffTubeAudio_PumpState(running)
  wait ( running ? 60.0 : 10.0 )
  running = !running
 }
}

void function RunoffTubeEffects_EnsureCentral()
{
 wait 3
 RunoffTubeEffects_StartCentral()
}
void function RunoffTubeEffects_StartCentral()
{
 if(file.centralStarted)return
 file.centralStarted=true
 int alt=GetParticleSystemIndex($"r1t_trash_tube_fast_hld_alt")
 foreach(vector pos in [<407.804,-423.839,24.3737>,<407.804,-423.839,408.374>])
  file.centralHandles.append(StartParticleEffectInWorldWithHandle(alt,pos,<0,90,0>))
 printt("RUNOFF_CENTRAL_TUBE_START",alt,file.centralHandles.len())
}

void function RunoffTubeEffects_EnsurePump()
{
 wait 3
 thread RunoffTubeEffects_PumpCycle()
 thread RunoffTubeAudio_Central()
}
void function RunoffTubeAudio_PumpState(bool running)
{
 entity player=GetLocalClientPlayer()
 if(!IsValid(player))return
 file.pumpsRunning=running
 printt("RUNOFF_PIPE_AUDIO_CYCLE",running?"ON":"OFF",3)
}
void function RunoffTubeAudio_Central()
{
 if(file.centralAudioStarted)return
 file.centralAudioStarted=true
 while(!IsValid(GetLocalClientPlayer()))wait 0.1

 printt("RUNOFF_PIPE_AUDIO_CENTRAL",3,"original TF1 emitter positions")
}

void function RunoffTubeAudio_Proximity()
{
 array<vector> positions=[Vector(-2256,-1226,340.5),Vector(-2256,-858,340.5),Vector(388,-1820,112),Vector(375.717,-362.266,643.628),Vector(438.955,-361.556,317.095),Vector(476.271,-402.222,116.708)]
 array<string> names=["runoff_emit_watertube_loop","runoff_emit_smallwatertube_loop","runoff_emit_metalwatertube_loop"]
 array<bool> active=[false,false,false]
 while(true)
 {
  entity player=GetLocalClientPlayer()
  if(IsValid(player))
  {
   array<bool> wanted=[false,false,false]
   if(IsAlive(player)&&GetGameState()==eGameState.Playing)
   {
    foreach(int i,vector pos in positions)
    {
     float radius=i<2?1500.0:600.0
     if(Distance(player.EyePosition(),pos)<radius&&(i>=3||file.pumpsRunning))
      wanted[i<2?0:(i==2?1:2)]=true
    }
   }
   foreach(int kind,string name in names)
   {
    if(wanted[kind]==active[kind])continue
    active[kind]=wanted[kind]
    if(active[kind])EmitSoundOnEntity(player,name)
    else StopSoundOnEntity(player,name)
    printt("RUNOFF_PIPE_LOCAL_PLAYBACK",kind,active[kind],player.GetOrigin())
   }
  }
  wait 0.5
 }
}

bool function RunoffTubeAudio_IsPumpRunning(){return file.pumpsRunning}
