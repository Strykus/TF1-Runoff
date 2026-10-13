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
 {}
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
 {}
}
void function RunoffTubeAudio_Central()
{
 if(file.centralAudioStarted)return
 file.centralAudioStarted=true
 while(!IsValid(GetLocalClientPlayer()))wait 0.1

 {}
}

bool function RunoffTubeAudio_IsPumpRunning(){return file.pumpsRunning}
