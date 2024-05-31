//================================================================================
// DD39Peeves.
//================================================================================

class DD39Peeves extends Characters;

/*var float fParticleTrailLife;
var ParticleFX ParticleFXActor;

event PostBeginPlay()
{
	ParticleFXActor = Spawn(Class'GhostTrail',,,Location);
	ParticleFXActor.Lifetime.Base = fParticleTrailLife;
}

function Tick (float DeltaTime)
{
	Super.Tick(DeltaTime);
	ParticleFXActor.SetLocation(Location + vect(0.00,0.00,-15.00));
}*/

defaultproperties
{
    // Physics=4
	Physics=PHYS_FLYING

    Mesh=SkeletalMesh'HPModels.skpeevesMesh'

    AmbientGlow=65

    CollisionRadius=40.00

    CollisionHeight=40.00

    bCollideWorld=False
	
	bCollideActors=False

    bBlockActors=False
	
    bBlockPlayers=False

    RotationRate=(Pitch=80000,Yaw=80000,Roll=80000)
	
	//fParticleTrailLife=1.00
}
