class DD39Searchlight extends HProp;

var() float fPitchAmount;
var() float fSwingSpeed;
//var() name CarSpottedEvent;
var() bool bStartOnLevelLoad;

var bool bStartedOnLoad;
var bool bSighted;

var float ElapsedTime;

var FlyingCarHarry PlayerHarry;


event PostBeginPlay()
{
	Super.PostBeginPlay();
	ElapsedTime = 0.0;
	
	foreach AllActors(Class'FlyingCarHarry',PlayerHarry)
	{
		break;
	}
}

event Trigger( Actor Other, Pawn EventInstigator )
{
	if ( bHidden )
	{
		bHidden = False;
	}
	
	if ( !IsInState('Swinging') )
	{
		GotoState('Swinging');
	}
}
	
// Thank you, MaxG =)
function SwingTick(float DeltaTime)
{
    local Rotator new_rot;
	local float new_pitch;

	new_pitch = ( Sin((ElapsedTime + DeltaTime) * fSwingSpeed) - Sin(ElapsedTime * fSwingSpeed) ) * fPitchAmount;
		
	ElapsedTime += DeltaTime;

	new_rot.Pitch = new_pitch;

	SetRotation(Rotation + new_rot);
}

event Touch(Actor Other)
{
	if ( Other == PlayerHarry )
	{
		if ( bHidden )
		{
			return;
		}
		
		if ( PlayerHarry.bIsCaptured )
		{
			return;
		}
		
		if ( bSighted )
		{
			return;
		}
		
		if ( IsInState('Swinging') && !bSighted )
		{
			//SetCollision(False);
			//TriggerEvent(CarSpottedEvent,Self,None);
			//GotoState('stateIdle');
			bSighted = True;
			PlayerHarry.TakeSightLevel(25.00,Self);
			//Log(string(self.name) $ " has spotted " $ PlayerHarry);
		}
	}
}

event Bump(Actor Other)
{
	Touch(Other);
}

auto state() stateIdle
{
	event BeginState()
	{
		if ( bStartOnLevelLoad && !bStartedOnLoad )
		{
			bStartedOnLoad = True;
			GotoState('Swinging');
		}
	}
}

state Swinging
{
	event BeginState()
	{
		ElapsedTime = 0.0;
	}
	
	event Tick(float DeltaTime)
	{	
		SwingTick(DeltaTime);
	}
	
	begin:
}

defaultproperties
{
	bStartOnLevelLoad=True
	
	//CarSpottedEvent="CarSpottedCS"
	
	Style=STY_Translucent

    Mesh=SkeletalMesh'Extended_Meshes.skSearchlight'
	
	Skins(0)=WetTexture'HPParticle.hp_fx.General.SnakeEyesWet'
	
	DrawScale=15.0
	
    AmbientGlow=100
	
	fPitchAmount=4096.0
	
	fSwingSpeed=1.0
	
	CollideType=CT_OrientedCylinder;
	
	CollisionRadius=96.0
	
	CollisionHeight=4768.0
	
	bAlignBottom=True
	
	bBlockActors=False
	
	bBlockCamera=False
	
	bBlockPlayers=False
	
	bCollideActors=True
	
	bProjTarget=False
}
