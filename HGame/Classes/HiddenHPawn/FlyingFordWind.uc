//================================================================================
// FlyingFordWind.
//
// Violence == 2.00 if WindDirection == From_Right
// Violence == 4.00 if WindDirection == From_Left
//================================================================================

class FlyingFordWind extends HiddenHPawn;

const BOOL_DEBUG_AI= false;

enum EWindDirection
{
	From_Left,
	From_Right
};

var() EWindDirection WindDirection;

//var bool bTouch;

var() bool bActive;
var() float violence;
var() Sound WindSound;

var float triggerRadius;
var float triggerHeight;

var FlyingCarHarry PlayerHarry;
var FlyingFordDirector Director;
var FlyingFordWindTrigger windTrigger;

var(VisualFX) ParticleFX fxWindParticleEffect;
var(VisualFX) Class<ParticleFX> fxWindParticleEffectClass;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	foreach AllActors(Class'FlyingCarHarry',PlayerHarry)
	{
		break;
	}
	
	foreach AllActors(Class'FlyingFordDirector',Director)
	{
		break;
	}
	
	if ( bActive )
	{
		StartWind();
	}
	
	//windTrigger = Spawn(Class'FlyingFordWindTrigger',self,,Location + Vec(0.0,0.0,10.0),Rotation);
	//windTrigger.SetCollisionSize(triggerRadius,triggerHeight);
}

event Tick (float DeltaTime)
{
	Super.Tick(DeltaTime);
	
	/*if ( fxWindParticleEffect != None )
	{
		fxWindParticleEffect.SetLocation(Location);
	}*/
	
	if ( bActive )
	{
		if ( HarryIsInMarker() )
		{
			PlayerHarry.fWindViolence = violence;
			
			if ( WindDirection == From_Left )
			{
				PlayerHarry.bLeftWind = True;
			}
			
			if ( WindDirection == From_Right )
			{
				PlayerHarry.bRightWind = True;
			}
		}
		else
		{
			PlayerHarry.bLeftWind = False;
			PlayerHarry.bRightWind = False;
			PlayerHarry.fWindViolence = 0.0;
		}
	}
}

/*event Touch(Actor Other)
{
	if ( Other == PlayerHarry )
	{
		if ( PlayerHarry.IsInState('stateShock') )
		{
			return;
		}
		PlayerHarry.GotoState('stateWind');
	}
}*/

function bool HarryIsInMarker()
{
	local Vector vDistance;

	vDistance = PlayerHarry.Location - Location;
	
	if ( VSize(vDistance) < CollisionRadius )
	{
		//cm("CAR IN MARKER");
		return True;
	}
	return False;
}

event Trigger (Actor Other, Pawn EventInstigator)
{
	bActive = !bActive;
	
	if ( bActive == True )
	{
		StartWind();
	}
	else
	{
		StopWind();
	}
}


function StartWind()
{
	//fxWindParticleEffect = Spawn(fxWindParticleEffectClass,,,Location);
	AmbientSound = WindSound;
}

function StopWind()
{
	/*if ( fxWindParticleEffect != None )
	{
		fxWindParticleEffect.Shutdown();
		fxWindParticleEffect.Destroy();
		fxWindParticleEffect = None;
	}*/
	PlayerHarry.bLeftWind = False;
	PlayerHarry.bRightWind = False;
	PlayerHarry.fWindViolence = 0.0;
	AmbientSound = None;
}

defaultproperties
{
    violence=2.00

    triggerRadius=800.00

    triggerHeight=300.00

    fxWindParticleEffectClass=Class'HPParticle.CloudWind'
	
	WindSound=Sound'Anglia_wind1'

    CollisionRadius=1024.00

    //CollisionWidth=55.00

    CollisionHeight=1024.00

    bCollideActors=True

    bCollideWorld=True
}