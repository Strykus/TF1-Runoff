global function RunoffReapers_Init
void function RunoffReapers_Init()
{
 if(GetMapName()!="mp_tf1_runoff")return
 bool enabled=GAMETYPE!="aitdm"
 SetConVarBool("runoff_reapers_enabled",enabled)
 AddClientCommandCallback("runoff_reapers",RunoffReapers_Command)
 AddSpawnCallback("npc_super_spectre",RunoffReapers_OnSpawn)
 {}
}
bool function RunoffReapers_Command(entity player,array<string> args)
{
 if(GetConVarInt("sv_cheats")!=1)return true
 bool enabled=args.len()>0&&args[0]=="1"
 SetConVarBool("runoff_reapers_enabled",enabled)
 if(!enabled)
 {
  foreach(entity npc in GetNPCArray())if(IsValid(npc)&&npc.GetClassName()=="npc_super_spectre")npc.Destroy()
 }
 {}
 return true
}
void function RunoffReapers_OnSpawn(entity npc){thread RunoffReapers_CheckSpawn(npc);}
void function RunoffReapers_CheckSpawn(entity npc)
{
 npc.EndSignal("OnDestroy")
 wait 0.1
 if(IsValid(npc)&&!RunoffReapers_Enabled())npc.Destroy()
}
