global function RunoffPipePlayback_Init
void function RunoffPipePlayback_Init()
{
 if(GetMapName()!="mp_tf1_runoff")return
 AddClientCommandCallback("runoff_pipe_sound_test",RunoffPipePlayback_Test)
 AddClientCommandCallback("runoff_pipe_sound_original",RunoffPipePlayback_Original)
 AddClientCommandCallback("runoff_pipe_sound_control",RunoffPipePlayback_Control)
 AddClientCommandCallback("runoff_pipe_ambient_on",RunoffPipePlayback_AmbientOn)
 AddClientCommandCallback("runoff_pipe_ambient_off",RunoffPipePlayback_AmbientOff)
 printt("PIPE_AUDIO_LAB_COMMANDS_READY")
}
bool function RunoffPipePlayback_Test(entity player,array<string> args)
{
 printt("PIPE_AUDIO_LAB_MANUAL_PIPE")
 return true
}
bool function RunoffPipePlayback_Original(entity player,array<string> args)
{
 StopSoundOnEntity(player,"runoff_emit_watertube_loop")
 EmitSoundOnEntityOnlyToPlayer(player,player,"runoff_emit_watertube_loop")
 printt("PIPE_AUDIO_LAB_MANUAL_ORIGINAL")
 return true
}
bool function RunoffPipePlayback_Control(entity player,array<string> args)
{
 EmitSoundOnEntityOnlyToPlayer(player,player,"Weapon_Kraber_Fire_1P")
 printt("PIPE_AUDIO_LAB_MANUAL_CONTROL")
 return true
}


bool function RunoffPipePlayback_AmbientOn(entity player,array<string> args)
{
 if(args.len()!=1||!IsAlive(player))return true
 int source=args[0].tointeger()
 if(source<0||source>5)return true
 StopSoundOnEntity(player,"weapon_r97_fire_first_1p")
 EmitSoundOnEntityOnlyToPlayer(player,player,"weapon_r97_fire_first_1p")
 printt("RUNOFF_PIPE_AMBIENT_ON",source,player.GetOrigin())
 return true
}
bool function RunoffPipePlayback_AmbientOff(entity player,array<string> args)
{
 FadeOutSoundOnEntity(player,"weapon_r97_fire_first_1p",0.35)
 printt("RUNOFF_PIPE_AMBIENT_OFF")
 return true
}
