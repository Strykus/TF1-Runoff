global function RunoffPipeAudio_Init
struct
{
 array<entity> pumpRefs
 array<entity> centralRefs
} file
void function RunoffPipeAudio_Init()
{
 if(GetMapName()!="mp_tf1_runoff")return
 AddClientCommandCallback("runoff_pipe_audio_on",RunoffPipeAudio_On)
 AddClientCommandCallback("runoff_pipe_audio_off",RunoffPipeAudio_Off)
 AddClientCommandCallback("runoff_pipe_audio_central",RunoffPipeAudio_Central)
 AddClientCommandCallback("runoff_pipe_source_on",RunoffPipeAudio_SourceOn)
 AddClientCommandCallback("runoff_pipe_source_off",RunoffPipeAudio_SourceOff)
 printt("RUNOFF_PIPE_AUDIO_SERVER_READY")
}
void function RunoffPipeAudio_CreateRefs()
{
 if(file.pumpRefs.len()!=0)return
 foreach(vector pos in [Vector(-2256,-1226,340.5),Vector(-2256,-858,340.5),Vector(388,-1820,112)])
  file.pumpRefs.append(CreateScriptRef(pos))
 foreach(vector pos in [Vector(375.717,-362.266,643.628),Vector(438.955,-361.556,317.095),Vector(476.271,-402.222,116.708)])
  file.centralRefs.append(CreateScriptRef(pos))
}
bool function RunoffPipeAudio_On(entity player,array<string> args)
{
 RunoffPipeAudio_CreateRefs()
 foreach(int i,entity emitter in file.pumpRefs)
 {
  string loop=i<2?"runoff_emit_watertube_loop":"runoff_emit_smallwatertube_loop"
  EmitSoundAtPositionOnlyToPlayer(TEAM_UNASSIGNED,emitter.GetOrigin(),player,"runoff_emit_watertube_start")
  EmitSoundAtPositionOnlyToPlayer(TEAM_UNASSIGNED,emitter.GetOrigin(),player,loop)
 }
 printt("RUNOFF_PIPE_AUDIO_SERVER_ON",player.GetEntIndex(),file.pumpRefs.len())
 return true
}
bool function RunoffPipeAudio_Off(entity player,array<string> args)
{
 RunoffPipeAudio_CreateRefs()
 foreach(int i,entity emitter in file.pumpRefs)
 {
  StopSoundAtPosition(emitter.GetOrigin(),i<2?"runoff_emit_watertube_loop":"runoff_emit_smallwatertube_loop")
  EmitSoundAtPositionOnlyToPlayer(TEAM_UNASSIGNED,emitter.GetOrigin(),player,"runoff_emit_watertube_stop")
 }
 printt("RUNOFF_PIPE_AUDIO_SERVER_OFF",player.GetEntIndex())
 return true
}
bool function RunoffPipeAudio_Central(entity player,array<string> args)
{
 RunoffPipeAudio_CreateRefs()
 foreach(entity emitter in file.centralRefs)EmitSoundAtPositionOnlyToPlayer(TEAM_UNASSIGNED,emitter.GetOrigin(),player,"runoff_emit_metalwatertube_loop")
 printt("RUNOFF_PIPE_AUDIO_SERVER_CENTRAL",player.GetEntIndex(),file.centralRefs.len())
 return true
}

string function RunoffPipeAudio_SourceName(int id)
{
 if(id<2)return "runoff_emit_watertube_loop"
 if(id==2)return "runoff_emit_smallwatertube_loop"
 return "runoff_emit_metalwatertube_loop"
}
entity function RunoffPipeAudio_Source(int id)
{
 return id<3?file.pumpRefs[id]:file.centralRefs[id-3]
}
bool function RunoffPipeAudio_SourceOn(entity player,array<string> args)
{
 if(args.len()!=1)return true
 int id=args[0].tointeger()
 if(id<0||id>5)return true
 RunoffPipeAudio_CreateRefs()
 vector pos=RunoffPipeAudio_Source(id).GetOrigin()
 EmitSoundAtPositionOnlyToPlayer(player.GetTeam(),pos,player,RunoffPipeAudio_SourceName(id))
 printt("RUNOFF_PIPE_SOURCE_PLAY",id,pos,player.GetOrigin())
 return true
}
bool function RunoffPipeAudio_SourceOff(entity player,array<string> args)
{
 if(args.len()!=1)return true
 int id=args[0].tointeger()
 if(id<0||id>5)return true
 RunoffPipeAudio_CreateRefs()
 StopSoundAtPosition(RunoffPipeAudio_Source(id).GetOrigin(),RunoffPipeAudio_SourceName(id))
 return true
}

