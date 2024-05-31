//================================================================================
// DD39BellowsSpawn.
//================================================================================

class DD39BellowsSpawn extends GenericSpawner;

defaultproperties
{
    GoodieToSpawn(0)=Class'Jellybean'

    Snds=(Opening=Sound'HPSounds.General.spawner_oil_can',Closing=None,Spawning=None)

    Limits=(Max=3,Min=2)

    StartBone=StartBone

    GoodieDelay=0.10

    Lives=2

    Mesh=SkeletalMesh'HPModels.skbellowsMesh'

    DrawScale=1.75

    AmbientGlow=75

    CollisionRadius=16.00

    CollisionHeight=10.00
	
	//DD39: mesh will display in-game exactly where the collision box is in-editor
	PrePivot=(X=-24,Y=0,Z=0)

    // CollideType=0
	CollideType=CT_AlignedCylinder
}
