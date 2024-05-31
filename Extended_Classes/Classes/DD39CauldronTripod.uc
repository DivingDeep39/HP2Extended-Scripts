//================================================================================
// DD39CauldronTripod.
//================================================================================

class DD39CauldronTripod extends HCauldron;

defaultproperties
{
    bAlignBottomAlways=True
	
	LODBias=1
	
	Mesh=SkeletalMesh'Extended_Meshes.skCauldronTripodMesh'

    AmbientGlow=75

    CollisionRadius=10.00

    CollisionHeight=14.00
	
	Physics=PHYS_NONE
	
	ShadowClass=Class'ActorShadow'
}