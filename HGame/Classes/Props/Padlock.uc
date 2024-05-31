//================================================================================
// Padlock.
//================================================================================

class Padlock extends HAlohomora;

//DD39: Added var for particles.
var ParticleFX ParticleFXActor;
//DD39: Rotator for Spawn_flash_4.
var rotator rTemp;

//DD39: Added PostBeginPlay for particles
event PostBeginPlay()
{
	Super.PostBeginPlay();
	ParticleFXActor = Spawn(Class'HPParticle.Lock',,,Location,Rotation);
	//ParticleFXActor.bPersistent = bPersistent;
	AttachToBone(ParticleFXActor, 'Box01');
	
	//DD39: Calculate rTemp.
	rTemp = Rotation;
	rTemp.yaw += 16384;
}

//DD39: Added event to destroy particles when triggered
event Destroyed()
{
	//DD39: Replace 'Rotation' with 'rTemp'.
	Spawn(Class'HPParticle.Spawn_flash_4',,,Location,rTemp);
	ParticleFXActor.Destroy();
	Super.Destroyed();
}

defaultproperties
{
	// attachedParticleClass(0)=Class'HPParticle.Lock'
	
	Mesh=SkeletalMesh'HProps.skPadlockMesh'
	
	DrawScale=1.20
	
	AmbientGlow=120
	
	CollisionHeight=16.00
}
