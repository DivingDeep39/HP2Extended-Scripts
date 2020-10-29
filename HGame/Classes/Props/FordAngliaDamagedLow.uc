//================================================================================
// FordAngliaDamagedLow.
//================================================================================

class FordAngliaDamagedLow extends HProp;

defaultproperties
{
    LODBias=1.20

    Mesh=SkeletalMesh'HProps.skFordAngliaDamagedLowMesh'

    AmbientGlow=25

    CollisionRadius=148.00

    CollisionWidth=64.00

    CollisionHeight=48.00

    // CollideType=2
	CollideType=CT_Box
}