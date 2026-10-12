global function RunoffMinimap_Init
void function RunoffMinimap_Init()
{
    if ( GetMapName() != "mp_tf1_runoff" )
        return
    thread RunoffMinimap_Verify()
}
void function RunoffMinimap_Verify()
{
    while ( !IsValid( GetLocalViewPlayer() ) )
        WaitFrame()
    wait 2.0
    NSSaveJSONFile( "verification.json", { map = GetMapName(), minimap = string( Minimap_GetAssetForKey( "minimap" ) ), x = Minimap_GetFloatForKey( "pos_x" ), y = Minimap_GetFloatForKey( "pos_y" ), scale = Minimap_GetFloatForKey( "scale" ), displayDist = Minimap_GetFloatForKey( "displayDist" ) } )
    print( "RUNOFF_MINIMAP_READY" )
}
