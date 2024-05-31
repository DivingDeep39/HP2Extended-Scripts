//================================================================================
// DD39SnapeMarker.
//================================================================================

class DD39SnapeMarker extends HPawn;

var() name SendCaughtEvent;
var() ProfSnape SnapeActor;
var() float SnapePeriphVision;
var() float SnapeSightRadius;
var() float SnapeSensesRadius;

var bool bOn;
var bool bInitialized;

event PreBeginPlay()
{
	Super.PreBeginPlay();
	bOn = False;
	bInitialized = False;
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
}

event Trigger( Actor Other, Pawn EventInstigator )
{
	if ( !bOn )
	{
		if ( !bInitialized )
		{
			if ( SnapeActor == None )
			{
				cm(name$" SNAPE NOT FOUND!");
				return;
			}
			else
			{
				cm(name$" found a Snape "$SnapeActor.name);
			}

			SnapeActor.PeripheralVision = SnapePeriphVision;
			SnapeActor.SightRadius = SnapeSightRadius;
			
			bInitialized = True;
		}

		bOn = True;
		
		if ( bOn )
		{
			if ( !bInitialized )
			{
				bOn = False;
				cm(name$" FAILED!");
				return;
			}
			else
			{
				cm(name$" is running");
				GotoState('stateOnAlert');
			}
		}
	}
	else
	{
		bOn = False;
		cm(name$" IS TRIGGERED OFF!");
	}
}

function HarryIsCaught()
{
	SnapeActor.Acceleration = vect(0.00,0.00,0.00);
	SnapeActor.Velocity = vect(0.00,0.00,0.00);
	SnapeActor.GotoState('stateIdle');
	
	if ( SendCaughtEvent != 'None' )
	{
		TriggerEvent(SendCaughtEvent,None,None);
	}
}

function bool HarryIsInMarker()
{
	local Vector vDistance;

	vDistance = PlayerHarry.Location - Location;
	
	if ( VSize(vDistance) < CollisionRadius + PlayerHarry.CollisionRadius )
	{
		return True;
	}
	return False;
}

function bool SnapeIsInMarker()
{
	local Vector vDistance;

	vDistance = SnapeActor.Location - Location;
	
	if ( VSize(vDistance) < CollisionRadius + SnapeActor.CollisionRadius )
	{
		return True;
	}
	return False;
}

function bool IsHarryClose()
{
	local Vector vDistance;

	vDistance = PlayerHarry.Location - SnapeActor.Location;
	
	if ( VSize(vDistance) < SnapeActor.SightRadius && SnapeActor.CanSee(PlayerHarry) )
	{
		return True;
	}
	return False;
}

function bool IsHarryBehind()
{
	local Vector vDistance;

	vDistance = PlayerHarry.Location - SnapeActor.Location;
	
	if ( VSize(vDistance) < SnapeSensesRadius && !SnapeActor.CanSee(PlayerHarry) )
	{
		return True;
	}
	return False;
}

auto state stateWait
{
begin:
}

state stateOnAlert
{
	event Tick (float DeltaTime)
	{		
		/*if (HarryIsInMarker())
		{
		  cm("HARRY IS IN MARKER");
		}
		
		if (SnapeIsInMarker())
		{
		  cm("IN MARKER IS SNAPE");
		}
		
		if (IsHarryBehind())
		{
		  cm("BEHIND YOU");
		}*/
		
		if ( bInitialized && bOn && HarryIsInMarker() && !PlayerHarry.bIsCaptured && !PlayerHarry.bKeepStationary && !PlayerHarry.IsInState('CelebrateCardSet') )
		{	
			if ( IsHarryClose() )
			{
				if ( !SnapeActor.IsInState('stateCutCapture') && !SnapeActor.IsInState('DoingBumpLine')  )
				{
					GotoState('stateBusted');				
				}
			}
			
			if ( SnapeIsInMarker() )
			{
				if ( IsHarryBehind() )
				{
					if ( !SnapeActor.IsInState('stateCutCapture') && !SnapeActor.IsInState('DoingBumpLine')  )
					{
						GotoState('stateBusted');
					}
				}
			}
		}
	}
	
begin:
}

state stateBusted
{
	event BeginState()
	{
		bOn = False;
		cm(SnapeActor.name$" caught "$PlayerHarry);
	}
	
begin:
	HarryIsCaught();
	GotoState('stateWait');
}

defaultproperties
{
    SnapePeriphVision=0.25
	
	SnapeSightRadius=768
	
	SnapeSensesRadius=64
	
	bHidden=True
	
	bBlockActors=False
	
	bBlockPlayers=False
	
	bCollideActors=True
	
	bCollideWorld=False
	
	bProjTarget=False
	
	DrawType=DT_Sprite

    Texture=Texture'HGame.HiddenPawn'

    CollisionRadius=50.00

    CollisionHeight=50.00
}
