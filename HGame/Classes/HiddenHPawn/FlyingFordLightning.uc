//================================================================================
// FlyingFordLightning.
//================================================================================

class FlyingFordLightning extends HiddenHPawn;

const BOOL_DEBUG_AI= false;

var() bool bActive;
var() name stormName;
var() float DamageAmount;

var bool bTouch;

var FlyingFordDirector Director;
var FlyingCarHarry PlayerHarry;
var FadeViewController FadeController;

var float fLightningViolence;
var int iLightningLoops;
var float fTimeBetweenchanges;

event PostBeginPlay()
{
	foreach AllActors(Class'FlyingCarHarry',PlayerHarry)
	{
		break;
	}
	
	foreach AllActors(Class'FlyingFordDirector',Director)
	{
		break;
	}
}

event Trigger(Actor Other, Pawn EventInstigator)
{
	bActive = !bActive;
}

event Touch (Actor Other)
{	
	if ( Other == PlayerHarry )
	{		
		if ( PlayerHarry.bIsCaptured )
		{
			return;
		}
		
		if ( !bTouch && bActive )
		{
			if ( PlayerHarry.IsInState('stateShock') )
			{
				return;
			}
			
			bTouch = True;
			
			DisableGroup();
			
			Director.OnTouchEvent(self,Other);
			DoFlashEffect();
			PlayerHarry.TakeCarDamage(DamageAmount,self);
			//PlayerHarry.GotoState('stateShock');
		}
	}
}

function DisableGroup()
{	
	local FlyingFordLightning stormFam;
	
	if ( stormName != '' )
	{
		foreach AllActors(Class'FlyingFordLightning',stormFam)
		{
			if ( stormFam.stormName == stormName )
			{
				stormFam.bTouch = True;
			}
		}
	}
}

function DoFlashEffect()
{
	FadeController = Spawn(Class'FadeViewController');
	FadeController.Init(0,255,255,255,0.5,True);
	//PlayerHarry.ShakeView(2,300,300);
	PlaySound(Sound'thunder2',SLOT_Interact,,,2048,RandRange(1.0,1.75));
	PlaySound(Sound'ExplG02',SLOT_Misc,,,2048,RandRange(0.75,1.25));
}

/*function UnTouch (Actor Other)
{
	Super.UnTouch(Other);
	if ( Other.IsA('harry') )
	{
		Director.OnUnTouchEvent(self,Other);
	}
}*/

event Bump (Actor Other)
{
	if ( BOOL_DEBUG_AI )
	{
		PlayerHarry.ClientMessage("I have been bumped ");
	}
	Touch(Other);
}

defaultproperties
{
    //fLightningViolence=5.00

    //iLightningLoops=15

    //fTimeBetweenchanges=0.20

    //Tag=''
	//fix for KW using '' instead of "" and added the name (to be compatible with the new engine) -AdamJD
    //Tag="FlyingFordLightning"

    CollisionRadius=20.00

    CollisionHeight=32.00

    bCollideActors=True

    bCollideWorld=True
	
	CollideType=CT_OrientedCylinder
	
	DamageAmount=25.00
}