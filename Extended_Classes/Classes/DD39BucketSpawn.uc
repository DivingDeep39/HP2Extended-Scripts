//================================================================================
// DD39BucketSpawn.
//================================================================================

class DD39BucketSpawn extends GenericSpawner;

defaultproperties
{
    GoodieToSpawn(0)=Class'Jellybean'

    Snds=(Opening=Sound'HPSounds.General.spawner_plant_pot',Closing=None,Spawning=None)

    Limits=(Max=3,Min=2)

    StartBone=StartBone

    GoodieDelay=0.20

    Mesh=SkeletalMesh'HPModels.skbucketMesh'

    DrawScale=1.00

    AmbientGlow=75

    CollisionRadius=20.00

    CollisionHeight=16.00

    // CollideType=0
	CollideType=CT_AlignedCylinder
}