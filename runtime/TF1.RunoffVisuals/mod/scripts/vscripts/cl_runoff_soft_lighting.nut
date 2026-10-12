global function RunoffSoftLighting_Init
global function RunoffSoftLighting_Shutdown
struct
{
 bool active=false
 float previousExposure
 float previousEnvmap
 bool previousColorCorrection
 bool previousDisableEntities
} file
void function RunoffSoftLighting_Init()
{
 if(GetMapName()!="mp_tf1_runoff" || file.active)return
 file.previousExposure=GetConVarFloat("mat_autoexposure_force_value")
 file.previousEnvmap=GetConVarFloat("mat_envmap_scale")
 file.previousColorCorrection=GetConVarBool("mat_colorcorrection")
 file.previousDisableEntities=GetConVarBool("mat_colcorrection_disableentities")
 printt("RUNOFF_SOURCE_COLORCORRECTION_STATE",file.previousColorCorrection,file.previousDisableEntities)
 SetConVarBool("mat_colorcorrection",true)
 SetConVarBool("mat_colcorrection_disableentities",false)
 file.active=true
 SetConVarFloat("mat_envmap_scale",0.60)
 SetConVarFloat("mat_autoexposure_force_value",0.55)
 printt("RUNOFF_SOFT_LIGHTING",file.previousExposure,file.previousEnvmap,GetConVarFloat("mat_autoexposure_force_value"),GetConVarFloat("mat_envmap_scale"))
}
void function RunoffSoftLighting_Shutdown()
{
 if(!file.active)return
 SetConVarFloat("mat_autoexposure_force_value",file.previousExposure)
 SetConVarFloat("mat_envmap_scale",file.previousEnvmap)
 SetConVarBool("mat_colorcorrection",file.previousColorCorrection)
 SetConVarBool("mat_colcorrection_disableentities",file.previousDisableEntities)
 file.active=false
}


