//================================================================================
// DD39PlaneColObj.
//================================================================================

class DD39PlaneColObj extends GenericColObj;

var name PlaneCrashEvent;
var FlyingCarHarry PlayerHarry;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	foreach AllActors(Class'FlyingCarHarry',PlayerHarry)
	{
		break;
	}
}

function bool HandleSpellFlipendo (optional baseSpell spell, optional Vector vHitLocation)
{
}

event Bump(Actor Other)
{
	Super.Bump(Other);
	
	Touch(Other);
}

event Touch (Actor Other)
{
	//Super.Touch(Other);
	
	//Log(string(PlayerHarry)$" has Touched "$string(self));
	
	if ( Other == PlayerHarry )
	{
		if ( PlayerHarry.bIsCaptured )
		{
			//Log(string(self)$": "$string(PlayerHarry)$" is in a Cutscene");
			return;
		}
		
		//Log("Car has touched "$string(self));
		
		TriggerEvent(PlaneCrashEvent,self,None);
	}
}

defaultproperties
{
	bBlockPlayers=False
	
	bBlockActors=False
	
	bBlockCamera=False
	
	bCollideActors=True
	
	bProjTarget=False
	
	bCollideWorld=False
	
	CollideType=CT_OrientedCylinder
	
	CollisionHeight=1984.00
	
	CollisionRadius=192.00
	
	DrawType=DT_Sprite
}