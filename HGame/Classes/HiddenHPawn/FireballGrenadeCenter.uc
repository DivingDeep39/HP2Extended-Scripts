//================================================================================
// FireballGrenadeCenter.
//================================================================================

class FireballGrenadeCenter extends HiddenHPawn;

var bool bTouch;
var float fLifetime;
var(VisualFX) ParticleFX fxGrenadeParticleEffect;
var float iDamage;

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
	fxGrenadeParticleEffect = Spawn(Class'Crabfireball');
	fLifeTimeTemp = fLifetime - 0.6;
	StartingBrightness = LightBrightness;
	EndingBrightness = 0;
	SetTimer(fLifetime,False);
	//fxGrenadeParticleEffect = Spawn(Class'Crabfireball');
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
	fxGrenadeParticleEffect.Shutdown();
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
	  Other.TakeDamage(iDamage,None,vect(0.00,0.00,0.00),vect(0.00,0.00,0.00),'None');
	  SetTimer(0.2,False);
	  bTouch = False;
	}
	PlaySound(Sound'spell_hit',SLOT_Interact,1.0,False,2000.0,1.0);
}

function Bump (Actor Other)
{
	Touch(Other);
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

auto state stateBegin
{
}

defaultproperties
{
    bTouch=True

    //DD39: default 2.50
	fLifetime=7.00

    DrawType=DT_None

    CollisionRadius=10.00

    CollisionHeight=10.00

    bCollideActors=True

    bCollideWorld=True
	
	// DD39
	LightType=LT_Steady

    // DD39
	LightEffect=LE_NonIncidence

    // DD39
	LightBrightness=400

    // DD39
	LightHue=22

    // DD39
	LightSaturation=72

    // DD39
	LightRadius=16
	
	// DD39
	Alpha=0.0;
	
	// DD39
	TotalTime=0.5
}