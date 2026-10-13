global function TF1_Runoff_Atmosphere_ClientInit
void function TF1_Runoff_Atmosphere_ClientInit()
{
 if ( GetMapName() != "mp_tf1_runoff" ) return
 PrecacheModel( $"models/tf1_runoff/atmosphere/redeye.mdl" )
 PrecacheModel( $"models/tf1_runoff/atmosphere/birmingham.mdl" )
 AddCallback_EntitiesDidLoad( TF1_Runoff_Atmosphere_Loaded )
}
void function TF1_Runoff_Atmosphere_Loaded()
{
 {}
 thread TF1_Runoff_SkyFlybys()
}
void function TF1_Runoff_ShipShow( entity ship )
{
 ship.EndSignal( "OnDestroy" )
 ship.Hide()
 wait 0.25
 ship.Show()
}
void function TF1_Runoff_ShipRemove( entity ship, float delay )
{
 wait delay
 if ( IsValid( ship ) ) ship.Destroy()
}
void function TF1_Runoff_SkyFlybys()
{
	array<entity> slowFlybyShips = []

	vector spawnOffset = Vector( 5.0, 0.0, -7.0 )

	table<string,float> skyboxWidth = { min = -300.0, max = 300.0 }
	table<string,float> skyboxLength = { min = -650.0, max = 300.0 }
	table<string,float> skyboxHeight = { min = 75.0, max = 200.0 }
	table<string,float> moveSpeed = { min = 14.0, max = 9.0 }
	float skyboxTotalLength = fabs( skyboxLength.max - skyboxLength.min )
	table<string,float> moveDuration = { min = skyboxTotalLength / moveSpeed.min, max = skyboxTotalLength / moveSpeed.max }
	table<string,float> forwardOffset = { min = 0.0, max = 200.0 }
	table<string,float> rightOffset = { min = -17.5, max = 17.5 }

	vector shipDirection = Vector( -0.580235, 0.813501, -0.039295 )

	vector spawnAng = VectorToAngles( shipDirection )
	vector right = AnglesToRight( spawnAng )

	int numShipsAcross = 8
	float shipSpacing = fabs( skyboxWidth.min - skyboxWidth.max ) / numShipsAcross

	array<array<int> > spawnOrder = [ [ 1, 6, 4, 0, 5, 3, 7, 2 ],
						 [ 0, 4, 2, 1, 6, 3, 7, 5 ],
						 [ 0, 1, 3, 6, 7, 4, 2, 5 ],
						 [ 5, 7, 3, 6, 1, 2, 4, 0 ],
						 [ 2, 7, 3, 5, 0, 4, 6, 1 ],
						 [ 5, 2, 4, 7, 6, 3, 1, 0 ] ]

	array<array<float> > heights = [ [ 0.9, 0.4, 0.6, 0.1, 0.2, 0.7, 1.0, 0.3 ],
					  [ 0.4, 0.9, 0.6, 1.0, 0.9, 0.7, 0.5, 0.6 ],
					  [ 0.8, 0.1, 0.7, 0.2, 0.5, 1.0, 0.4, 0.3 ],
					  [ 0.6, 0.5, 0.7, 0.9, 1.0, 0.6, 0.9, 0.4 ],
					  [ 0.3, 1.0, 0.7, 0.2, 0.1, 0.6, 0.4, 0.9 ],
					  [ 0.3, 0.4, 1.0, 0.5, 0.2, 0.7, 0.1, 0.8 ] ]

	array<array<float> > durations = [ [ 0.6, 0.8, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
						[ 0.4, 0.8, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 	[ 0.6, 0.3, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 	[ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.4 ],
					 	[ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.3, 0.6 ],
					 	[ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.6 ] ]

	array<array<float> > forwardOffsets = [ [ 0.0, 0.8, 1.0, 0.0, 0.1, 0.6, 0.2, 0.3 ],
							 [ 0.0, 0.8, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 		 [ 0.0, 0.3, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 		 [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.6 ],
					 		 [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.4 ],
					 		 [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.3, 0.6 ] ]

	array<array<float> > rightOffsets = [ [ 0.6, 0.8, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
						   [ 0.4, 0.8, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 	   [ 0.6, 0.3, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 	   [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.6 ],
						   [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.4 ],
					 	   [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.3, 0.6 ] ]

	array<array<int> > shipModels = [ [ 1, 1, 1, 0, 0, 0, 0, 0 ],
						 [ 0, 0, 1, 0, 0, 0, 0, 0 ],
						 [ 1, 0, 1, 0, 0, 0, 0, 1 ],
						 [ 0, 0, 0, 0, 0, 1, 1, 1 ],
						 [ 0, 0, 0, 0, 0, 1, 0, 0 ],
						 [ 1, 0, 0, 0, 0, 1, 0, 1 ] ]

	while ( GetGameState() <= eGameState.SuddenDeath )
	{
		foreach( i, so in spawnOrder )
		{
			foreach( index, val in so )
			{
				float shipMoveDuration = GraphCapped( durations[ i ][ index ], 0.0, 1.0, moveDuration.min, moveDuration.max )

				float offsetForward = skyboxLength.min
				offsetForward += GraphCapped( forwardOffsets[ i ][ index ], 0.0, 1.0, forwardOffset.min, forwardOffset.max )

				float offsetRight = skyboxWidth.min + ( shipSpacing / 2.0 ) + ( shipSpacing * val )
				offsetRight += GraphCapped( rightOffsets[ i ][ index ], 0.0, 1.0, rightOffset.min, rightOffset.max )

				float offsetHeight = GraphCapped( heights[ i ][ index ], 0.0, 1.0, skyboxHeight.min, skyboxHeight.max )

				vector spawnPos = < -11896.0, -12024.0, -3984.0 > + spawnOffset + ( shipDirection * offsetForward ) + ( right * offsetRight ) + Vector( 0, 0, offsetHeight )
				vector moveToPos = spawnPos + ( shipDirection * fabs( skyboxLength.min - skyboxLength.max ) )

				asset model = shipModels[ i ][ index ] == 0 ? $"models/tf1_runoff/atmosphere/redeye.mdl" : $"models/tf1_runoff/atmosphere/birmingham.mdl"
				entity ship = CreateClientsideScriptMover( model, spawnPos, spawnAng )
				slowFlybyShips.append( ship )

				thread TF1_Runoff_ShipShow( ship )
				ship.NonPhysicsMoveTo( moveToPos, shipMoveDuration, 0, 0 )
				thread TF1_Runoff_ShipRemove( ship, shipMoveDuration )

				wait( 1.0 )
			}

			wait( 24.0 )
		}
	}

	}
