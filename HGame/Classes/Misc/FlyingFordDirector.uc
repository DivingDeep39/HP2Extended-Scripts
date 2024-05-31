//================================================================================
// FlyingFordDirector.
//================================================================================

//this is an unused file -AdamJD

class FlyingFordDirector extends Director;

enum CarLocations {
  LOC_NONE,
  LOC_SAFE,
  LOC_TOWN
};

var FlyingCarHarry PlayerHarry;
var FlyingFordPathGuide guide;
var FlyingFordHedwig Hedwig;
var Boeing747 Plane;
var DynamicInterpolationPoint Points[2];
var baseConsole Console;
var int SafeRefCount;
var int TownRefCount;
var float fDefaultRandomDialog;
var float fRandomDialog;
var() float fOverTownMeter;
var() float fOverSheepMeter;
var() float fOverPlaneMeter;
var() float fResetMeter;
//var() float HedwigMaxDistance;
//var() float HedwigPrepivotDistanceFront;
//var() float HedwigPrepivotDistanceUp;
var float fWindViolence;
var Vector vDirection;
var float fTurbulence;
var Vector distanceMinusZ;
var FlyingFordLightning lightningZone;
var ThunderLightning lightning;
var bool blightningStrike;
var Vector strikeDirection;
var Vector tempDistance;
var float fLightningViolence;
var int iLightningLoops;
var float fTimeBetweenchanges;
var CarLocations CarLocation;

var() float CameraTrailDist;

/*var() float BoostExpireTime;
var() float BoostRechargeTime;
var float fBoostCharge;
var bool bBoostExpired;
var bool bBoostRecharged;
var bool bBoosting;*/

var bool bPhaseTwo;
var() float HudDelaySeconds;

var DD39CarBoostBar CarBoostBar;
var DD39CarHealthBar CarHealthBar;
var MuggleMeterManager MuggleMeter;

//var float fGuideTrackDist;
//var() float GuideTrackDistMin;
//var() float GuideTrackDistMax;

function PreBeginPlay()
{
  //local DynamicInterpolationPoint p;
  //local int Counter;

  Super.PreBeginPlay();
// JL001A:
  foreach AllActors(Class'FlyingCarHarry',PlayerHarry)
  {
    // goto JL001A;
	break;
  }
  
  /*foreach AllActors(Class'MuggleMeterManager',MuggleMeter)
  {
    // goto JL002F;
	break;
  }*/
  /*foreach AllActors(Class'Boeing747',Plane)
  {
    // goto JL0044;
	break;
  }*/
  guide = Spawn(Class'FlyingFordPathGuide',,,PlayerHarry.Location,PlayerHarry.Rotation);
  guide.PathName = PlayerHarry.GuidePathName;
  guide.AirSpeedNormal = PlayerHarry.AirSpeedNormal;
  PlayerHarry.guide = guide;
  HudDelaySeconds = 3;
  //Hedwig = Spawn(Class'FlyingFordHedwig',,,Location + Vec(50.0,50.0,-50.0),Rotation);
}

function PostBeginPlay()
{
  Super.PostBeginPlay();
  //CarLocation = LOC_SAFE;
  //fBoostCharge = 1.0;
  CarBoostBar = Spawn(Class'DD39CarBoostBar');
  CarBoostBar.Show(False);
  CarHealthBar = Spawn(Class'DD39CarHealthBar');
  CarHealthBar.Show(False);
  MuggleMeter = Spawn(Class'MuggleMeterManager');
  MuggleMeter.Show(False);
  PlayerHarry.MuggleMeter = MuggleMeter;
  MuggleMeter.SetOwner(PlayerHarry);
  MuggleMeter.AttachToOwner();
  //guide.GotoState('Fly');
  InitialState = 'GameIntro';
  //Hedwig.SetOwner(guide);
  //Hedwig.AttachToOwner();
  //Hedwig.bTrailerPrePivot = True;
  //Hedwig.PrePivot = Vec(HedwigPrepivotDistanceFront,0.0,HedwigPrepivotDistanceUp);
}

/*function BoostTick(float DeltaTime)
{
	local float fChargeDelta;
	
	if ( !PlayerHarry.bAllowBoost )
	{
		return;
	}
	
	if ( ( PlayerHarry.bBroomBoost != 0 ) &&
		( GetCurBoostCharge() > 0.0 ) && !bBoostExpired )
	{
		fChargeDelta = GetMaxBoostCharge() - GetCurBoostCharge();
		
		fBoostCharge -= (DeltaTime / BoostExpireTime * fChargeDelta );
		
		if ( GetCurBoostCharge() <= 0.0 )
		{
			Log(string(self)$": Boost has EXPIRED!");
			bBoostExpired = True;
			CarBoostBar.bBoostExpired = True;
			fBoostCharge = 0.0;
			guide.SplineSpeed = PlayerHarry.AirSpeedNormal;
		}
	}
  
	if ( ( ( PlayerHarry.bBroomBoost == 0 ) &&
		( GetCurBoostCharge() < GetMaxBoostCharge() ) ) || bBoostExpired )
	{
		fChargeDelta = GetMaxBoostCharge() - GetCurBoostCharge();
		
		fBoostCharge += (DeltaTime / BoostRechargeTime * fChargeDelta );
		
		if ( GetCurBoostCharge() >= GetMaxBoostCharge() )
		{
			fBoostCharge = GetMaxBoostCharge();
			
			Log(string(self)$": Boost has RECHARGED!");
			
			if ( bBoostExpired )
			{
				bBoostExpired = False;
				CarBoostBar.bBoostExpired = False;
			}
		}
	}
}*/

/*function float GetMaxBoostCharge()
{
	return 1.0;
}

function float GetCurBoostCharge()
{
	return fBoostCharge;
}*/

function SetCameraToFollowGuide()
{
  // harry.Cam.SetCameraMode(4);
  PlayerHarry.Cam.SetCameraMode(CM_Quidditch);
  PlayerHarry.Cam.SetTargetActor(guide.Name);
  PlayerHarry.Cam.SetZOffset(25.0);
  PlayerHarry.Cam.CamTarget.bRelative = True;
  PlayerHarry.Cam.SetDistance(CameraTrailDist);
  PlayerHarry.Cam.SetRotTightness(10.0);
  PlayerHarry.Cam.SetMoveTightness(10.0);
  PlayerHarry.Cam.SetMoveSpeed(1200.0);
}

function OnTouchEvent (Pawn Subject, Actor Object)
{
  if ( Object.Tag == 'FlyingFordSafe' )
  {
    //IncrementSafeCount();
  } else //{
    if ( Object.Tag == 'FlyingFordTown' )
    {
      //IncrementTownCount();
    } else //{
      if ( Object.Tag == 'FlyingFordWind' )
      {
        Log("Entered a windy area");
      }
      if ( Object.Tag == 'FlyingFordWindTrigger' )
      {
        PlayerHarry.ClientMessage("The trigger has been touched");
      } else //{
        if ( Object.Tag == 'FlyingFordLightning' )
        {
          //lightningZone = FlyingFordLightning(Object);
          //GotoState('GameLightning');
        }
      //}
    //}
  //}
  /*if ( SetCarLocation() )
  {
    UpdateHud();
  }*/
}

function OnUnTouchEvent (Pawn Subject, Actor Object)
{
  /*if ( Object.Tag == 'FlyingFordSafe' )
  {
    DecrementSafeCount();
  } else //{
    if ( Object.Tag == 'FlyingFordTown' )
    {
      DecrementTownCount();
    } else //{
      if ( Object.Tag == 'FlyingFordLightning' )
      {
        if ( IsInState('GameLightning') )
        {
          PlayerHarry.ClientMessage("Return to state GamePlay from an UNTouch message  " $ string(GetStateName()));
          GotoState('GamePlay');
        }
      }
    //}
  //}
  if ( SetCarLocation() )
  {
    UpdateHud();
  }*/
}

function OnHitEvent (Pawn Subject)
{
  PlayerHarry.ClientMessage(string(Subject.Name) $ " hit an obstacle");
}

function OnCutSceneEvent (name CutSceneTag)
{
  PlayerHarry.ClientMessage("CutScene " $ string(CutSceneTag) $ " triggered Director");
}

function OnTriggerEvent (Actor Other, Pawn EventInstigator)
{
  PlayerHarry.ClientMessage(string(Other) $ " triggered Director with " $ string(EventInstigator));
  if ( Other != None )
  {
    PlayerHarry.ClientMessage("We have triggered an airplane");
    GotoState('GameAirplane');
  }
}

function Trigger (Actor Other, Pawn EventInstigator)
{
  local CutScene CutScene;
  local CutScript CutScript;

  CutScene = CutScene(Other);
  CutScript = CutScript(Other);
  if ( (CutScene != None) || (CutScript != None) )
  {
    OnCutSceneEvent(CutScene.Tag);
  } else {
    OnTriggerEvent(Other,EventInstigator);
  }
}

function OnPlayerPossessed()
{
  Super.OnPlayerPossessed();
  Log("Player possessed");
  Console = baseConsole(PlayerHarry.Player.Console);
  //TriggerEvent('FlyingFordIntro',self,None);
}

function OnPlayerDying()
{
  PlayerHarry.ClientMessage("Player dying...");
}

function OnPlayersDeath()
{
  PlayerHarry.ClientMessage("Player died; restarting game");
  Level.Game.RestartGame();
}

function OnActionKeyPressed()
{
  PlayerHarry.ClientMessage("Action key pressed");
}

function StartTurbulence (float violence, Vector Direction)
{
  fWindViolence = violence;
  vDirection = Direction;
  GotoState('GameWind');
}

function StartLightning()
{
  local ThunderLightning tempObject;
  local name nameOfStorm;

  PlayerHarry.ClientMessage("StartLightning has been entered");
  nameOfStorm = lightningZone.stormName;
  foreach AllActors(Class'ThunderLightning',tempObject)
  {
    if ( tempObject.stormName == nameOfStorm )
    {
      lightning = tempObject;
    }
  }
  fLightningViolence = lightningZone.fLightningViolence;
  iLightningLoops = lightningZone.iLightningLoops;
  fTimeBetweenchanges = lightningZone.fTimeBetweenchanges;
}

function IncrementSafeCount()
{
  SafeRefCount++;
  Log("Safe Count : " $ string(SafeRefCount));
}

function DecrementSafeCount()
{
  SafeRefCount--;
  if ( SafeRefCount < 0 )
  {
    SafeRefCount = 0;
  }
  Log("Safe Count : " $ string(SafeRefCount));
}

function IncrementTownCount()
{
  TownRefCount++;
  Log("Town Count : " $ string(TownRefCount));
}

function DecrementTownCount()
{
  TownRefCount--;
  if ( TownRefCount < 0 )
  {
    TownRefCount = 0;
  }
  Log("Town Count : " $ string(TownRefCount));
}

function bool SetCarLocation()
{
  local CarLocations currentLocation;

  currentLocation = CarLocation;
  if ( SafeRefCount > 0 )
  {
    CarLocation =  LOC_SAFE;
  } else //{
    if ( TownRefCount > 0 )
    {
      CarLocation =  LOC_TOWN;
    } else {
      CarLocation =  LOC_NONE;
    }
  //}
  if ( currentLocation == CarLocation )
  {
    return False;
  } else {
    return True;
  }
}

function UpdateHud()
{
  /*switch (CarLocation)
  {
    // case 1:
	case LOC_SAFE:
		Log("Resetting the MuggleMeter");
		MuggleMeter.MugglesOutOfRange(fResetMeter);
		break;
	// case 2:
	case LOC_TOWN:
		Log("MuggleMeter going up by fOverTownMeter");
		MuggleMeter.MugglesInRange(fOverTownMeter);
		break;
	// case 0:
	case LOC_NONE:
		Log("MuggleMeter going up by fOverSheepMeter. Look there's a sheep!");
		MuggleMeter.MugglesInRange(fOverSheepMeter);
		break;
	default:
		Log("We are in an unknown location");
		break;
  }*/
}

function OnPlayerCapture()
{
	guide.DestroyControllers();
	PlayerHarry.bAllowBoost=False;
	CarBoostBar.Show(False);
	CarHealthBar.Show(False);
	MuggleMeter.Show(False);
	GotoState('GameIntro');
}

function OnPlayerRelease()
{
	PlayerHarry.Cam.SetCameraMode(CM_Quidditch);
}

function bool CutCommand (string Command, optional string cue, optional bool bFastFlag)
{
  local string sActualCommand;

  sActualCommand = ParseDelimitedString(Command," ",1,False);
  Log("sActualCommand is = "$sActualCommand);
  
  if ( sActualCommand ~= "GameIntro" )
  {
    //Log("Setting GameIntro");
	GotoState('GameIntro');
	CutCue(cue);
	return True;
  }
  else if ( sActualCommand ~= "GamePlay" )
  {
    Log("Setting GamePlay");
	GotoState('GamePlay');
	CutCue(cue);
	return True;
  }
  else if ( sActualCommand ~= "GameWon" )
  {
    //Log("Setting GameWon");
	GotoState('GameWon');
	CutCue(cue);
	return True;
  }
  else if ( sActualCommand ~= "GameRestart" )
  {
    //Log("Setting GameRestart");
	GotoState('GameRestart');
	CutCue(cue);
	return True;
  }
  else if ( sActualCommand ~= "GameAirplane" )
  {
    GotoState('GameAirplane');
	CutCue(cue);
	return True;
  }
  else if ( sActualCommand ~= "GameLightning" )
  {
    GotoState('GameLightning');
	CutCue(cue);
	return True;
  }
  else if ( sActualCommand ~= "GoGuide" )
  {
    guide.PathName = PlayerHarry.GuidePathName;
	guide.AirSpeedNormal = PlayerHarry.AirSpeedNormal;
	guide.SetLocation(PlayerHarry.Location);
	guide.SetRotation(PlayerHarry.Rotation);
	guide.GotoState('Fly');
	CutCue(cue);
	return True;
  }
  else if ( sActualCommand ~= "CamFollowGuide" )
  {
    SetCameraToFollowGuide();
	CutCue(cue);
	return True;
  }
  else if ( sActualCommand ~= "LockOffsetRange" )
  {
    Log("LockOffsetRange called");
	PlayerHarry.LockOffsetRange();
	CutCue(cue);
	return True;
  }
  else if ( sActualCommand ~= "UnlockOffsetRange" )
  {
    Log("UnlockOffsetRange called");
	PlayerHarry.UnlockOffsetRange();
	CutCue(cue);
	return True;
  }
  else if ( sActualCommand ~= "PhaseTwo" || sActualCommand ~= "Phase2" )
  {
	Log("Car is in Phase Two");
	bPhaseTwo = True;
	guide.Destroy();
	guide = Spawn(Class'FlyingFordPathGuide',,,PlayerHarry.Location,PlayerHarry.Rotation);
	guide.PathName = PlayerHarry.GuidePathName;
	guide.AirSpeedNormal = PlayerHarry.AirSpeedNormal;
	PlayerHarry.guide = guide;
	CutCue(cue);
	return True;
  }
  else if ( sActualCommand ~= "Set" )
  {
    return CutCommand_HandleSet(Command,cue,bFastFlag);
  }
  else
  {
      return Super.CutCommand(Command,cue,bFastFlag);
  }
}

function bool CutCommand_HandleSet (string Command, optional string cue, optional bool bFastFlag)
{
	//local Actor A;
	local string sVarName;
	local string sVarValue;
	local int I;

	sVarName = ParseDelimitedString(Command," ",2,False);
	sVarValue = ParseDelimitedString(Command," ",3,False);
	sVarName = Caps(sVarName);
	switch (sVarName)
	{
		case "CARPATH":
			//cm(string(self) $ " Setting CarPath to: " $ sVarValue $ " in: "$string(guide));
			guide.PathName = name(sVarValue);
			Log(string(guide)$ " has a new PathName = "$ guide.PathName);
			PlayerHarry.GuidePathName = name(sVarValue);
			Log(string(PlayerHarry)$ " has a new GuidePathName = "$ PlayerHarry.GuidePathName);
			break;
		default:
	}
	
	if(bFastFlag)
	{
		CutNotifyActor.CutCue(cue);
		return True;
	}
	CutCue(cue);
	return True;
}

state GameIntro
{
  function BeginState()
  {
  }
  
  function OnCutSceneEvent (name CutSceneTag)
  {
    //MuggleMeter.BeginDetection();
    //GotoState('GamePlay');
  }
  
}

state GamePlay
{
	event BeginState()
	{
	  PlayerHarry.ClientMessage("We are in GamePlay.");
	  PlayerHarry.StopFlyingOnPath();
	  PlayerHarry.AirSpeed = 10.0;
	  PlayerHarry.Deceleration = PlayerHarry.AirSpeedNormal - PlayerHarry.AirSpeed;
	  PlayerHarry.SetLookForTarget(guide);
	  SetCameraToFollowGuide();
	  SetTimer(HudDelaySeconds,False);
	  /*if ( !bPhaseTwo )
	  {
		
		//CarBoostBar.Show(True);
		//CarHealthBar.Show(True);
		//PlayerHarry.bAllowBoost=True;
		//PlayerHarry.bAllowBrake=True;
	  }
	  else
	  {
		CarBoostBar.Show(False);
		CarHealthBar.Show(True);
		PlayerHarry.bAllowBoost=False;
		//PlayerHarry.bAllowBrake=False;
	  }*/
	  //Hedwig.LoopAnim('Drop');
	}
	
	/*event Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);
		BoostTick(DeltaTime);
	}*/
	
	event Timer()
	{
		if ( !bPhaseTwo )
		{
			MuggleMeter.Show(True);
			CarHealthBar.Show(True);
			CarBoostBar.Show(True);
			PlayerHarry.bAllowBoost=True;
		}
		else
		{
			PlayerHarry.bAllowBoost=False;
			CarBoostBar.Show(False);
			CarHealthBar.Show(True);
			MuggleMeter.Show(True);
		}
	}
}

state GameWon
{
}

state GameRestart
{
begin:
  OnPlayersDeath();
}

state GameAirplane
{
  function BeginState()
  {
    Plane.StartTransPath();
  }
  
  function MovePoints()
  {
    local Vector pos1;
    local Vector pos2;
    local Vector vCarDirection;
    local Vector vUp;
    local Vector vRight;
    local Vector p1Ahead;
    local Vector p1Side;
    local Vector p2Ahead;
    local Vector p2Side;
  
    vCarDirection = vector(PlayerHarry.Rotation);
    vUp = Vec(0.0,0.0,1.0);
    vRight = vCarDirection Cross vUp;
    p1Ahead = PlayerHarry.Location + (vCarDirection * 300);
    p1Side = PlayerHarry.Location + (vRight * 200);
    p2Ahead = PlayerHarry.Location + (vCarDirection * 200);
    p2Side = PlayerHarry.Location + (vCarDirection * 0);
    Points[0].SetLocation(p1Ahead + p1Side);
    Points[1].SetLocation(p2Ahead + p2Side);
  }
  
  function SetPlaneOnPath()
  {
    Plane.StartOnPath();
  }
  
}

state GameWind
{
  function BeginState()
  {
    fTurbulence = 0.0;
    PlayerHarry.LoopAnim('flyingeratic');
    PlayerHarry.ClientMessage("IN the beginning  :  " $ string(PlayerHarry.vCurrentTetherDistance));
  }
  
  function EndState()
  {
    PlayerHarry.LoopAnim('Flying');
    PlayerHarry.ClientMessage("IN the end  :  " $ string(PlayerHarry.vCurrentTetherDistance));
  }
  
  function float windDirectionConst()
  {
    local Vector vRight;
    local Vector vGuideDirection;
    local Vector vUp;
  
    vGuideDirection = vector(guide.Rotation);
    vUp = Vec(0.0,0.0,1.0);
    vRight = vGuideDirection Cross vUp;
    if ( vDirection Dot vRight > 0 )
    {
      return -1.0;
    } else {
      return 1.0;
    }
  }
  
  function Vector windDirectionVector()
  {
    local Vector vRight;
    local Vector vGuideDirection;
    local Vector vUp;
    local Vector vLeft;
  
    vGuideDirection = vector(guide.Rotation);
    vUp = Vec(0.0,0.0,1.0);
    vRight = vGuideDirection Cross vUp;
    vLeft =  -vRight;
    if ( vDirection Dot vRight > 0 )
    {
      vRight.Z = vDirection.Z;
      return vRight;
    } else {
      vLeft.Z = vDirection.Z;
      return vLeft;
    }
  }
  
  function Tick (float DeltaTime)
  {
    Super.Tick(DeltaTime);
    if ( fTurbulence < VSize(fWindViolence * vDirection) )
    {
      fTurbulence += VSize(fWindViolence * vDirection) * DeltaTime;
      PlayerHarry.vTurbulence += fWindViolence * windDirectionVector() * DeltaTime;
    } else {
      distanceMinusZ = windDirectionVector();
      distanceMinusZ.Z = 0.0;
      PlayerHarry.sideDistance += VSize(fWindViolence * distanceMinusZ) * windDirectionConst();
      PlayerHarry.upDistance += PlayerHarry.vTurbulence.Z;
      PlayerHarry.vTurbulence = Vec(0.0,0.0,0.0);
      GotoState('GamePlay');
    }
  }
  
}

state GameLightning
{
  function BeginState()
  {
    StartLightning();
  }
  
  function Tick (float DeltaTime)
  {
    Super.Tick(DeltaTime);
    if ( lightning.bLightningActive == True )
    {
      GotoState('StruckByLightning');
    }
  }
  
}

state StruckByLightning
{
  function Tick (float DeltaTime)
  {
    Super.Tick(DeltaTime);
    tempDistance = strikeDirection;
    tempDistance.Z = 0.0;
    PlayerHarry.sideDistance += VSize(fLightningViolence * tempDistance) * sideDirectionConst();
    tempDistance = strikeDirection;
    tempDistance.X = 0.0;
    tempDistance.Y = 0.0;
    PlayerHarry.upDistance += VSize(fLightningViolence * tempDistance) * upDirectionConst();
    PlayerHarry.vTurbulence = Vec(0.0,0.0,0.0);
  }
  
  function float sideDirectionConst()
  {
    local Vector vRight;
    local Vector vGuideDirection;
    local Vector vUp;
  
    vGuideDirection = vector(guide.Rotation);
    vUp = Vec(0.0,0.0,1.0);
    vRight = vGuideDirection Cross vUp;
    if ( strikeDirection Dot vRight > 0 )
    {
      return -1.0;
    } else {
      return 1.0;
    }
  }
  
  function float upDirectionConst()
  {
    local Vector vGuideDirection;
  
    vGuideDirection = vector(guide.Rotation);
    if ( vGuideDirection Dot strikeDirection > 0 )
    {
      return -1.0;
    } else {
      return 1.0;
    }
  }
  
  function Vector OutofControl()
  {
    local Vector newSideDirection;
    local Vector newUpDirection;
    local Vector vRight;
    local Vector vGuideDirection;
    local Vector vUp;
    local float fRandPercentSide;
    local Vector newVector;
    local float newYaw;
    local float newPitch;
  
    vGuideDirection = vector(guide.Rotation);
    vUp = Vec(0.0,0.0,1.0);
    vRight = vGuideDirection Cross vUp;
    fRandPercentSide = FRand();
    if ( Rand(2) == 0 )
    {
      newSideDirection = vRight * (fLightningViolence * fRandPercentSide);
      newYaw = fLightningViolence * (fRandPercentSide * 500);
    } else {
      newSideDirection =  -vRight * (fLightningViolence * fRandPercentSide);
      newYaw =  -fLightningViolence * (fRandPercentSide * 500);
    }
    if ( Rand(2) == 0 )
    {
      newUpDirection = Vec(0.0,0.0,1.0) * fLightningViolence * (1 - fRandPercentSide);
      if ( fLightningViolence * (1 - fRandPercentSide) * 500 < PlayerHarry.PitchLimitUp )
      {
        newPitch = fLightningViolence * (1 - fRandPercentSide) * 500;
      } else {
        newPitch = PlayerHarry.PitchLimitUp;
      }
    } else {
      newUpDirection = Vec(0.0,0.0,-1.0) * fLightningViolence * (1 - fRandPercentSide);
      if ( fLightningViolence * (1 - fRandPercentSide) * 500 < PlayerHarry.PitchLimitDown )
      {
        newPitch =  -fLightningViolence * (1 - fRandPercentSide) * 500;
      } else {
        newPitch = PlayerHarry.PitchLimitDown;
      }
    }
    PlayerHarry.fLightningYaw = newYaw;
    PlayerHarry.fLightningPitch = newPitch;
    newVector = newSideDirection + newUpDirection;
    return newVector;
  }
  
 begin:
  // if ( iLightningLoops > 0 )
  while ( iLightningLoops > 0 )
  {
    strikeDirection = OutofControl();
    Sleep(fTimeBetweenchanges);
    iLightningLoops--;
    // goto JL0000;
  }
  PlayerHarry.fLightningYaw = 0.0;
  PlayerHarry.fLightningPitch = 0.0;
  GotoState('GamePlay');
}

defaultproperties
{
    fDefaultRandomDialog=5.00

    fOverTownMeter=5.00

    fOverSheepMeter=2.00

    fOverPlaneMeter=5.00

    fResetMeter=10.00

    //HedwigMaxDistance=400.00

    //HedwigPrepivotDistanceFront=200.00

    //HedwigPrepivotDistanceUp=100.00

    //Tag=''
	//fix for KW using '' instead of "" and added the name (to be compatible with the new engine) -AdamJD
    //Tag="Director"
	
	CameraTrailDist=384.00
	
	//GuideTrackDistMax=300.00
	
	//BoostExpireTime=3.0
	
	//BoostRechargeTime=6.0
	
	HudDelaySeconds=3
}
