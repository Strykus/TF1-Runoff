global function RunoffSoftLighting_Init
global function RunoffSoftLighting_Shutdown
struct
{
 bool active=false
 int previousTextureAnisotropy
 float previousSun
 float previousSky
 float previousExposure
 float previousEnvmap
 bool previousColorCorrection
 bool previousDisableEntities
} file
void function RunoffSoftLighting_Init()
{
 if(GetMapName()!="mp_tf1_runoff" || file.active)return
 file.previousTextureAnisotropy=GetConVarInt("mat_forceaniso")
 file.previousSun=GetConVarFloat("mat_sun_scale")
 file.previousSky=GetConVarFloat("mat_sky_scale")
 file.previousExposure=GetConVarFloat("mat_autoexposure_force_value")
 file.previousEnvmap=GetConVarFloat("mat_envmap_scale")
 file.previousColorCorrection=GetConVarBool("mat_colorcorrection")
 file.previousDisableEntities=GetConVarBool("mat_colcorrection_disableentities")
 {}
 SetConVarBool("mat_colorcorrection",true)
 SetConVarBool("mat_colcorrection_disableentities",false)
 // Native STBSP data controls texture streaming; keep anisotropic filtering.
 SetConVarInt("mat_forceaniso",16)
 file.active=true
 SetConVarFloat("mat_sun_scale",0.40)
 SetConVarFloat("mat_sky_scale",0.40)
 SetConVarFloat("mat_envmap_scale",0.60)
 SetConVarFloat("mat_autoexposure_force_value",0.55)
 {}
}
void function RunoffSoftLighting_Shutdown()
{
 if(!file.active)return
 SetConVarInt("mat_forceaniso",file.previousTextureAnisotropy)
 SetConVarFloat("mat_sun_scale",file.previousSun)
 SetConVarFloat("mat_sky_scale",file.previousSky)
 SetConVarFloat("mat_autoexposure_force_value",file.previousExposure)
 SetConVarFloat("mat_envmap_scale",file.previousEnvmap)
 SetConVarBool("mat_colorcorrection",file.previousColorCorrection)
 SetConVarBool("mat_colcorrection_disableentities",file.previousDisableEntities)
 file.active=false
}


