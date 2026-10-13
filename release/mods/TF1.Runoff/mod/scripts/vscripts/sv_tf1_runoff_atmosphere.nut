global function TF1_Runoff_Atmosphere_ServerInit
void function TF1_Runoff_Atmosphere_ServerInit()
{
 if ( GetMapName() != "mp_tf1_runoff" ) return
 PrecacheModel( $"models/tf1_runoff/atmosphere/redeye.mdl" )
 PrecacheModel( $"models/tf1_runoff/atmosphere/birmingham.mdl" )
 {}
}
