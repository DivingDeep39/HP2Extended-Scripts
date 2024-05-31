//================================================================================
// FlyingFordPathGuide.
//================================================================================

class FlyingFordPathGuide extends HiddenHPawn;

const BOOL_DEBUG_AI= false;
var FlyingFordDirector Director;
var name PathName;
var float AirSpeedNormal;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	foreach AllActors(Class'FlyingFordDirector',Director)
	{
		break;
	}
	SetCollision(False,False,False);
	// DD39:
	bCollideWorld = False;
}

function Touch (Actor Other)
{
	Super.Touch(Other);
}

function UnTouch (Actor Other)
{
	Super.UnTouch(Other);
}

function Bump (Actor Other)
{
	if ( BOOL_DEBUG_AI )
	{
		PlayerHarry.ClientMessage("Target: I have been bumped ");
	}
	Touch(Other);
}

state Fly
{	
	begin:
		FollowSplinePath(PathName,AirSpeedNormal,0.0);
		//Log(string(self)$": flying on SplinePathName = "$string(SplinePathName)$" ; SplineSpeed = "$SplineSpeed$" ; FirstSplinePoint = "$string(FirstSplinePoint)$" ; DestSplinePoint = "$string(DestSplinePoint));
}

defaultproperties
{
    //Tag=''
	//fix for KW using '' instead of "" and added the name (to be compatible with the new engine) -AdamJD
    //Tag="FlyingFordPathGuide"
	CutName="PathGuideCar"
	
	bHidden=True

    DrawType=DT_Mesh

    Mesh=SkeletalMesh'HPModels.skfirecrabMesh'

    CollisionRadius=22.00

    CollisionHeight=22.00
	
	bCollideActors=False

    bCollideWorld=False

    bBlockPlayers=False
}