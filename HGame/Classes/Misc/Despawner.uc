//================================================================================
// Despawner.
// by Omega
//================================================================================

class Despawner extends HPawn;

var() name EventName;

function Touch (Actor Other)
{
	Super.Touch(Other);
	//DD39: moved to CheckDespawn(Other) in Tick
	/*if (  !HPawn(Other).bDespawnable )
	{
		return;
	}
	if ( harry(Other) == PlayerHarry )
	{
		return;
	}
	if ( (EventName != 'None') &&  !HPawn(Other).bDespawned )
	{
		HPawn(Other).TriggerEvent(EventName,None,None);
		PlayerHarry.ClientMessage("Send event.................." $ string(EventName));
	}
	HPawn(Other).SetDespawnFlag();*/
	CheckDespawn(Other);
}

//DD39: created Tick
event Tick (float DeltaTime)
{
	local Actor a;

	foreach TouchingActors(class'Actor', a)
	{
		CheckDespawn(a);
	}
}

//DD39: created CheckDespawn(Other)
function CheckDespawn (Actor Other)
{
	if (  !HPawn(Other).bDespawnable )
	{
		return;
	}
	if ( harry(Other) == PlayerHarry )
	{
		return;
	}
	if ( (EventName != 'None') &&  !HPawn(Other).bDespawned )
	{
		HPawn(Other).TriggerEvent(EventName,None,None);
		PlayerHarry.ClientMessage("Send event.................." $ string(EventName));
	}
	HPawn(Other).SetDespawnFlag();
}

defaultproperties
{
    bHidden=True

    // DrawType=1
	DrawType=DT_Sprite

    Texture=Texture'Engine.S_Keypoint'

    CollisionRadius=30.00

    CollisionWidth=30.00

    CollisionHeight=30.00

    // CollideType=2
	CollideType=CT_Box

    bBlockActors=False

    bBlockPlayers=False
}
