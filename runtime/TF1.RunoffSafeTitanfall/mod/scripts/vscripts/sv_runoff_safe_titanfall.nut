global function RunoffSafeTitanfall_Init
void function RunoffSafeTitanfall_Init()
{
 if(GetMapName()!="mp_tf1_runoff")return
 SetRequestTitanGamemodeRules(RunoffSafeTitanfall_Allowed)
 {}
}
bool function RunoffSafeTitanfall_RoofBlocked(vector p)
{
 if(p.z<520 || p.z>740)return false
 if(p.y>= -4032 && p.y<= -3200 && ((p.x>= -1024 && p.x<= -320)||(p.x>= -128 && p.x<=640)))return true
 if(p.x>=1550 && p.x<=2400 && p.y>= -1500 && p.y<= -750)return true
 return false
}
bool function RunoffSafeTitanfall_Allowed(entity player,vector origin)
{
 if(Riff_TitanQueueLimit()>0 && GetTitanCountForTeam(player.GetTeam())>=Riff_TitanQueueLimit())return false
 bool blocked=RunoffSafeTitanfall_RoofBlocked(origin)
 if(!blocked)
 {
  TraceResults body=TraceHull(origin+<0,0,2>,origin+<0,0,3>,< -60,-60,0 >,<60,60,235>,[player],TRACE_MASK_PLAYERSOLID,TRACE_COLLISION_GROUP_NONE)
  blocked=body.startSolid || body.allSolid
 }
 if(!blocked)
 {
  foreach(vector offset in [<0,0,0>,< -48,-48,0 >,<48,-48,0>,< -48,48,0 >,<48,48,0>])
  {
   vector start=origin+offset+<0,0,236>
   TraceResults roof=TraceLine(start,start+<0,0,4096>,[player],TRACE_MASK_PLAYERSOLID,TRACE_COLLISION_GROUP_NONE)
   if(roof.startSolid || (roof.fraction<1 && !roof.hitSky)){blocked=true;break;}
  }
 }
 if(blocked)
 {
  {}
  EmitSoundOnEntityOnlyToPlayer(player,player,"coop_sentrygun_deploymentdeniedbeep")
  SendHudMessage(player,"Titanfall requires clear space and open sky.",-1,0.4,255,255,255,255,0.15,3.0,0.5)
  return false
 }
 {}
 return true
}
