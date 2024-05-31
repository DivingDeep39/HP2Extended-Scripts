//================================================================================
// Fireball.
//================================================================================

class Fireball extends HiddenHPawn;

var bool bTouch;
var float fLifetime;
var Vector CurrentDir;

// DD39: New vars for lerp
var bool bTimeUp;
var float Alpha;
var float CurTime;
var float TotalTime;
var byte StartingBrightness;
var byte EndingBrightness;
var float fLifeTimeTemp;

function PostBeginPlay()
{
	// DD39: Set the timer time
	fLifeTimeTemp = fLifetime - 1.05;
	StartingBrightness = LightBrightness;
	EndingBrightness = 0;
	SetTimer(fLifetime,False);
}

// DD39: Added Tick event to handle lerp
event Tick( float DeltaTime )
{
  Super.Tick(DeltaTime);
  
	if ( !bTimeUp )
	{
		fLifeTimeTemp -= DeltaTime;
	}
	
	if ( fLifeTimeTemp <= 0 )
	{	
		bTimeUp = True;
		CurTime = fclamp(CurTime + DeltaTime/TotalTime, 0.0, 1.0);
		LightBrightness = Lerp(EaseOut(CurTime), StartingBrightness, EndingBrightness);
	}
}
		

function Timer()
{
	Destroy();
}

function Touch (Actor Other)
{
	if ( Pawn(Other) == Instigator )
	{
		return;
	}
	if ( (Other == PlayerHarry) && (bTouch) )
	{
	  Other.TakeDamage(5,None,vect(0.00,0.00,0.00),vect(0.00,0.00,0.00),'None');
	  bTouch = False;
	}
	PlaySound(Sound'spell_hit',SLOT_Interact,1.0,False,2000.0,1.0);
}

function bounce (Vector HitNormal)
{
	SetLocation(OldLocation);
	Velocity *= 0.89999998;
	Velocity = MirrorVectorByNormal(Velocity,HitNormal);
	CurrentDir = Vector(Rotation);
	CurrentDir += HitNormal;
	SetRotation(rotator(CurrentDir));
}

function Bump (Actor Other)
{
	Touch(Other);
}

function HitWall (Vector HitNormal, Actor HitWall)
{
	bounce(HitNormal);
}

// DD39: Function to handle lerp
function float Flip(float F)
{
  return 1 - F;
}

// DD39: Function to handle lerp
function float EaseOut(float F)
{
  return Flip(Flip(F) ** 2);
}

defaultproperties
{
    bTouch=True

    fLifetime=3.00

    attachedParticleClass(0)=Class'HPParticle.Crabfire2'

    attachedParticleClass(1)=Class'HPParticle.CrabSmoke'

    attachedParticleOffset(0)=(X=0.00,Y=0.00,Z=-32.00)

    DrawType=DT_None

    CollisionRadius=10.00

    CollisionHeight=22.00

    bCollideActors=True

    bCollideWorld=True
	
	// DD39
	LightType=LT_Steady

    // DD39
	LightEffect=LE_NonIncidence

    // DD39
	LightBrightness=201

    // DD39
	LightHue=22

    // DD39
	LightSaturation=72

    // DD39
	LightRadius=10
	
	// DD39
	Alpha=0.0;
	
	// DD39
	TotalTime=1.0
}