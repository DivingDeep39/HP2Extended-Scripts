//================================================================================
// FlyingCarHarry.
//================================================================================

class FlyingCarHarry extends harry
  Config(User);

//const NUM_WOOSH_SOUNDS= 4;
//const NUM_SLOW_WOOSH_SOUNDS= 5;
//const NUM_HIT_SOUNDS= 3;
//const fMaxTimeSameAvoidDir= 1.0;

const fBroomSensitivityDivisor= 16384.0;
const fJoyBroomSensitivityDivisor= 13312.0;
const FPS_FIX= 60.00;

enum EControlDevice {
  DEVICE_Button,
  DEVICE_Mouse,
  DEVICE_Joystick,
  DEVICE_Gamepad
};

var() int AirSpeedNormal;
var() int AirSpeedBoost;
//var() int AirSpeedBrake;
var() int PitchLimitUp;
var() int PitchLimitDown;
var() int WallDamage;
var() float MaxSpeed;
var() float SlowdownRadius;
var() name GuidePathName;

var() float TrackingOffsetRange_Horz;
var() float TrackingOffsetRange_Vert;
var() float fTargetTrackDist;

var FlyingFordDirector Director;
var FlyingFordPathGuide guide;
var FlyingFordLightning Lightning;

var float fBroomSensitivityConst;
var float fBroomSensitivityDividend;
var float SavedfBroomSensitivityConst;
var float SavedfBroomSensitivityDividend;
var float SavedTrackingOffsetRange_Horz;
var float SavedTrackingOffsetRange_Vert;
var float fWindViolence;
var bool bLeftWind;
var bool bRightWind;

var float fPitchControl;
var float fYawControl;
var float fRotationRateYaw;
var float fLightningYaw;
var float fLightningPitch;
var Vector vTurbulence;
var float sideDistance;
var float upDistance;
var Vector vCurrentTetherDistance;

var bool bInvincible;
var bool bAuxBoost;
var int Deceleration;
var bool bHasEverBoosted;
var bool bHasEverBraked;
var bool bActioned;
var bool bWasActioning;
var float fMousePitch;
var float fMouseYaw;
var float fBroomSensitivity;
var float fJoyBroomSensitivity;
var EControlDevice eYawControlDevice;
var EControlDevice ePitchControlDevice;
var bool bLastYawNeg;
var bool bLastPitchNeg;
var bool bHit;
var bool bHitWall;
var bool bHittingWall;
var int WallAvoidanceYaw;
var float fWallAvoidanceRate;
var float fLastTimeAvoidedWall;
var bool bLastAvoidanceRight;
var float fTimeForNextError;
var Vector TargetError;
var float fTargetTrackHorzOffset;
var float fTargetTrackVertOffset;
//var float fNextTimeSafeToWoosh;
var bool bEasingUpToSpeed;
var Vector vDodgeVel;
var name PrimaryAnim;
var name SecondaryAnim;
var Sound CarSound;
var() Sound BoostSound;
var Sound MainBroomSound;
var Sound HitSounds[3];
var Sound SlowWooshSounds[5];
var Sound WooshSounds[4];
var InterpolationManager IM;
//var DynamicInterpolationPoint TransPath[2];
//var int iTransPoint;
var string CutCommandCue;
var ParticleFX Trail;
var Actor LookForTarget;
var float PathSpeed;
var bool bAllowBoost;
//var bool bAllowBrake;
var bool bBoostPlaying;

var() float BoostExpireTime;
var() float BoostRechargeTime;
var float fBoostCharge;
var bool bBoostExpired;
var bool bBoostRecharged;
var bool bBoosting;
//var bool bTrailEmitting;
var DD39CarBoostBar CarBoostBar;
var StatusItemHealth siHealth;
var float CarHealth;
var() name CarStruckEvent;
var float SightLevel;
var() name CarSightedEvent;
var MuggleMeterManager MuggleMeter;

/*struct StormGroup
{
    var Array<FlyingFordLightning> LightningPawn;
    var Name stormName;
};
var() Array<StormGroup> Storms;*/

function PreBeginPlay()
{
  Super.PreBeginPlay();
  ForEach AllActors(Class'FlyingFordDirector',Director)
  {
	break;
  }
  bInvincible = True;
  bAuxBoost = False;
  Deceleration = 0;
  bHasEverBoosted = False;
  bHasEverBraked = False;
  bActioned = False;
  bWasActioning = False;
  PathSpeed = IPSpeed;
}

function PostBeginPlay()
{
  Super.PostBeginPlay();
  SetPhysics(PHYS_Flying);
  PrimaryAnim = 'Flying';
  SecondaryAnim = '';
  LoopAnim(PrimaryAnim);
  LookForTarget = None;
  //AmbientSound = CarSound;
  fRotationRateYaw = 20000.0;
  RotationRate.Yaw = 50000;
  RotationRate.Roll = 6000;
  RotationRate.Pitch = 24000;
  //fBroomSensitivityDividend = 0.05;
  fBroomSensitivityDividend = 0.4;
  fBroomSensitivityConst = 350.0;
  fBroomSensitivity = fBroomSensitivityDividend / fBroomSensitivityDivisor;
  fJoyBroomSensitivity = fBroomSensitivityDividend / fJoyBroomSensitivityDivisor;
  fTargetTrackHorzOffset = RandRange( -TrackingOffsetRange_Horz,TrackingOffsetRange_Horz);
  fTargetTrackVertOffset = RandRange( -TrackingOffsetRange_Vert,TrackingOffsetRange_Vert);
  fMouseYaw = 0.0;
  fMousePitch = 0.0;
  eYawControlDevice = DEVICE_Button;
  bLastYawNeg = False;
  bLastPitchNeg = False;
  bEasingUpToSpeed = True;
  bHit = False;
  bHitWall = False;
  bHittingWall = False;
  fLastTimeAvoidedWall = -1.0;
  //fTargetTrackDist = 200.0;
  fBoostCharge = 1.0;

  SavedfBroomSensitivityDividend = fBroomSensitivityDividend;
  SavedfBroomSensitivityConst = fBroomSensitivityConst;
  SavedTrackingOffsetRange_Horz = TrackingOffsetRange_Horz;
  SavedTrackingOffsetRange_Vert = TrackingOffsetRange_Vert;

  SpawnTrail();
}

function SpawnTrail()
{	
	local rotator rTemp;
	
	if ( Trail == None )
	{	
		rTemp = Rotation;
		rTemp.yaw *= Abs(Rotation.yaw);
		
		Trail = Spawn(Class'DD39Fordtrail',self,,,rTemp);
		AttachToBone(Trail,'Trunk');
	}
}

function Vector SideDirection (float fYawControl)
{
  local Vector vGuideDirection;
  local Vector vUp;
  local Vector vDown;
  local Vector vRight;
  local Vector vLeft;

  vGuideDirection = vector(guide.Rotation);
  vUp = Vec(0.0,0.0,1.0);
  vDown = Vec(0.0,0.0,-1.0);
  vLeft = vGuideDirection Cross vDown;
  return vLeft;
}			

event Possess()
{
  Super.Possess();
  Log("FlyingCarHarry in State " $ string(GetStateName()) $ ".");
  Director.OnPlayerPossessed();
  SetPhysics(PHYS_Flying);
}

event TravelPostAccept()
{
  Super.TravelPostAccept();
}

event PlayerInput (float DeltaTime)
{	
	Super.PlayerInput(DeltaTime);

	if ( bIsCaptured )
	{
		return;
	}
	
	if ( bAllowBoost )
	{
		if ( bCarBoost != 0 && !bBoostExpired && !IsInState('stateShock') )
		{
			/*if ( bBroomBrake != 0 )
			{
				//DisableTrail();
				Trail.bEmit = False;
				bBoostPlaying = False;
				guide.SplineSpeed = AirSpeedNormal;
				return;
			}*/
			
			guide.SplineSpeed = AirSpeedBoost;
			Trail.bEmit = True;
			PlayBoostSound();
			
			if ( GetCurBoostCharge() > 0.0 && !HPConsole(Player.Console).menuBook.bIsOpen  )
			{		
				//Log("GetCurBoostCharge = "$GetCurBoostCharge());
				
				fBoostCharge -= DeltaTime / BoostExpireTime;
				
				//Log("EXPIRING = "$fBoostCharge);
				
				if ( fBoostCharge < 0.0 )
				{
					//Log(string(self)$": Boost has EXPIRED! "$fBoostCharge);
					bBoostExpired = True;
					fBoostCharge = 0.0;
					guide.SplineSpeed = AirSpeedNormal;
				}
			}
		}
		else if ( ( bCarBoost == 0 || bBoostExpired ) && !IsInState('stateShock') )
		{
			Trail.bEmit = False;
			bBoostPlaying = False;
			
			if ( GetCurBoostCharge() < GetMaxBoostCharge() && !HPConsole(Player.Console).menuBook.bIsOpen )
			{	
				fBoostCharge += DeltaTime / BoostRechargeTime;
			
				/*if ( fBoostCharge < GetMaxBoostCharge() )
				{
					Log("RECHARGIIIIING"$fBoostCharge);
				}*/
				
				if ( fBoostCharge > GetMaxBoostCharge() )
				{
					fBoostCharge = GetMaxBoostCharge();
				
					//Log(string(self)$": Boost has RECHARGED! "$fBoostCharge);
				
					if ( bBoostExpired )
					{
						bBoostExpired = False;
					}
				}
			}
		}
	}
	
	/*if ( bAllowBrake )
	{
		if ( bBroomBrake != 0 && bCarBoost == 0 && !IsInState('stateShock'))
		{
			if ( bCarBoost != 0 )
			{
				return;
			}
			guide.SplineSpeed = AirSpeedBrake;
		}
	}*/
	
	if ( ( bCarBoost == 0 || !bAllowBoost ) /*&& ( bBroomBrake == 0 || !bAllowBrake )*/ )
	{
		guide.SplineSpeed = AirSpeedNormal;
	}
}

function float GetMaxBoostCharge()
{
	return 1.0;
}

function float GetCurBoostCharge()
{
	return fBoostCharge;
}

function float GetCarHealth()
{
	return CarHealth;
}

function TakeCarDamage(float Damage, Pawn Instigator)
{
	Log("TakeCarDamage called by "$string(Instigator)$" inflicted Damage of "$string(Damage));
	
	CarHealth = GetCarHealth() - Damage;
	
	//Log("Remaining health is "$GetCarHealth());
	
	if ( GetCarHealth() > 0 )
	{
		GotoState('stateShock');
	}
	else
	{
		//Log("Health is "$GetCarHealth()$" so game over is triggered");
		TriggerEvent(CarStruckEvent,self,None);
	}
}

function float GetSightLevel()
{
	return SightLevel;
}

function TakeSightLevel(float Sighting, Pawn Instigator)
{
	Log("TakeSightLevel called by "$string(Instigator)$" inflicted Sighting of "$string(Sighting));
	
	SightLevel += Sighting;
	
	//Log("Current Sighting level is "$GetSightLevel());
	
	MuggleMeter.PlayMeterSound();
	
	if ( SightLevel > 75.00 )
	{
		//Log("SightLevel is "$GetSightLevel()$" so game over is triggered");
		MuggleMeter.PlayMeterSound();
		TriggerEvent(CarSightedEvent,self,None);
	}
}

/*function BoostTick(float DeltaTime)
{
	if ( GetCurBoostCharge() > 0.0 && !HPConsole(Player.Console).menuBook.bIsOpen )
	{		
		Log("GetCurBoostCharge = "$GetCurBoostCharge());
				
		fBoostCharge -= DeltaTime / BoostExpireTime;
				
		Log("EXPIRING = "$fBoostCharge);
				
		if ( fBoostCharge < 0.0 )
		{
			Log(string(self)$": Boost has EXPIRED! "$fBoostCharge);
			bBoostExpired = True;
			//CarBoostBar.bBoostExpired = True;
			fBoostCharge = 0.0;
			guide.SplineSpeed = AirSpeedNormal;
		}
	}
	
	if ( bBoostExpired )
	{
		CarBoostBar.bGreyBar = True;
	}
			
	if ( GetCurBoostCharge() < GetMaxBoostCharge() && !HPConsole(Player.Console).menuBook.bIsOpen )
	{	
		fBoostCharge += DeltaTime / BoostRechargeTime;
		
		if ( fBoostCharge < GetMaxBoostCharge() )
		{
			Log("RECHARGIIIIING"$fBoostCharge);
		}
				
		if ( fBoostCharge > GetMaxBoostCharge() )
		{
			fBoostCharge = GetMaxBoostCharge();
				
			Log(string(self)$": Boost has RECHARGED! "$fBoostCharge);
				
			if ( bBoostExpired )
			{
				bBoostExpired = False;
				CarBoostBar.bGreyBar = False;
			}
		}
	}
}*/
			
function PlayBoostSound()
{
	if ( !bBoostPlaying )
	{
		if ( SoundSlotOccupied(SLOT_Misc) )
		{
			return;
		}
		bBoostPlaying = True;
		PlaySound(BoostSound,SLOT_Misc);
	}
}

function DoCapture()
{
  StopFlyingOnPath();
  Director.OnPlayerCapture();
  SetSecondaryAnimation('');
  DesiredRotation = Rotation;
  DesiredRotation.Pitch = 0;
  SetRotation(DesiredRotation);
  //bTrailEmitting=False;
  Trail.bEmit = False;
  bBoostPlaying = False;
  GotoState('stateCutIdle');
}

function LockOffsetRange()
{
	//Log("LockOffset received");
	TrackingOffsetRange_Horz = 0;
	TrackingOffsetRange_Vert = 0;
	//Log("Lock Horz = "$TrackingOffsetRange_Horz);
	//Log("Lock Vert = "$TrackingOffsetRange_Vert);
}

function UnlockOffsetRange()
{
	//Log("UnlockOffset received");
	TrackingOffsetRange_Horz = SavedTrackingOffsetRange_Horz;
	TrackingOffsetRange_Vert = SavedTrackingOffsetRange_Vert;
	//Log("Restored Horz = "$TrackingOffsetRange_Horz);
	//Log("Restored Vert = "$TrackingOffsetRange_Vert);
}

function bool CutCommand (string Command, optional string cue, optional bool bFastFlag)
{
  local string sActualCommand;
  local bool bResult;

  sActualCommand = ParseDelimitedString(Command," ",1,False);
  if ( sActualCommand ~= "Capture" )
  {
    DoCapture();
    return Super.CutCommand(Command,cue,bFastFlag);
  } else //{
    if ( sActualCommand ~= "Release" )
    {
      Director.OnPlayerRelease();
	  bResult = Super.CutCommand(Command,cue,bFastFlag);
      IPSpeed = PathSpeed;
      bInterpolating_IgnoreRot = False;
      bCollideWorld = True;
      SetCollision(True,True,True);
      bEasingUpToSpeed = True;
      return bResult;
    } else //{
      if ( sActualCommand ~= "FlyOnPath" )
      {
        return CutCommand_FlyOnPath(Command,cue,bFastFlag);
      } else {
        return Super.CutCommand(Command,cue,bFastFlag);
      }
    //}
  //}
}

function bool CutCommand_FlyOnPath (string Command, optional string cue, optional bool bFastFlag)
{
  local InterpolationPoint IP;
  local string Token;
  local int I;
  local name PathName;
  local int StartPoint;

  PathName = name(ParseDelimitedString(Command," ",2,False));
// JL0027:
  StartPoint = 0;
  I = 2;
  do
  {
	  ++I;
	  Token = ParseDelimitedString(Command," ",I,False);
	  if ( Token != "" )
	  {
		if ( Left(Token,Len("Start=")) ~= "Start=" )
		{
		  Token = Mid(Token,Len("start="));
		  StartPoint = -1;
		  foreach AllActors(Class'InterpolationPoint',IP,PathName)
		  {
			if ( IP.CutName ~= Token )
			{
			  StartPoint = IP.Position;
			  break;
			}
		  }
		  if ( StartPoint == -1 )
		  {
			CutErrorString = "No Spline Point on path '" $ string(PathName) $ "' with CutName '" $ Token $ "'";
			CutCue(cue);
			return False;
		  }
		} else {
		  ClientMessage("**** Warning:" $ string(self) $ ":FlyOnPath option '" $ Token $ "' not recognized.  Ignoring.");
		  Log("**** Warning:" $ string(self) $ ":FlyOnPath option '" $ Token $ "' not recognized.  Ignoring.");
		}
	  }
  }
  until(Token == "");
  
  if ( bFastFlag )
  {
    foreach AllActors(Class'InterpolationPoint',IP,PathName)
    {
      if ( IP.bEndOfPath )
      {
        SetLocation(IP.Location);
        SetRotation(IP.Rotation);
		break;
      }
    }
    CutCue(cue);
  } else {
    CutCommandCue = cue;
    FlyOnPath(PathName,StartPoint);
  }
  return True;
}

function SetPrimaryAnimation (name NewPrimaryAnim, optional float Rate, optional float TweenTime, optional float MinRate, optional EAnimType Type, optional name RootBone)
{
  if ( NewPrimaryAnim != PrimaryAnim )
  {
    PrimaryAnim = NewPrimaryAnim;
    if ( PrimaryAnim != 'None' )
    {
      LoopAnim(PrimaryAnim,,TweenTime,MinRate);
    }
    if ( SecondaryAnim != 'None' )
    {
      LoopAnim(SecondaryAnim,,TweenTime);
    }
  }
}

function SetSecondaryAnimation (name NewSecondaryAnim, optional float Rate, optional float TweenTime, optional float MinRate, optional EAnimType Type, optional name RootBone)
{
  if ( NewSecondaryAnim != SecondaryAnim )
  {
    SecondaryAnim = NewSecondaryAnim;
    if ( PrimaryAnim != 'None' )
    {
      LoopAnim(PrimaryAnim,,TweenTime);
    }
    if ( SecondaryAnim != 'None' )
    {
      LoopAnim(SecondaryAnim,,TweenTime,MinRate);
    }
  }
}

function DeterminePrimaryAnim()
{
  local float Speed;

  Speed = VSize(Velocity);
  if ( (bCarBoost != 0 || bAuxBoost) && bAllowBoost )
  {
	SetPrimaryAnimation( 'flyingeratic',,2.0 );
  }
  else
  {
    SetPrimaryAnimation('Flying',,2.0);
  }
  //Trail.ParentBlend = Min(Speed / 200, 1);
}

/*function DeterminePrimaryAnim()
{
  local float Speed;

  Speed = VSize(Velocity);
  if (  !bHitWall &&  !bHit )
  {
    if ( (Rotation.Roll > 1000) && (Rotation.Roll < 32768) )
    {
      SetPrimaryAnimation('Turn_Right',,1.0);
    } else //{
      if ( (Rotation.Roll < 65536 - 1000) && (Rotation.Roll > 32768) )
      {
        SetPrimaryAnimation('Turn_Left',,1.0);
      } else //{
        if ( (Rotation.Pitch > 1000) && (Rotation.Pitch < 32768) )
        {
          SetPrimaryAnimation('Pull_Up',,1.0);
        } else //{
          if ( (Rotation.Pitch < 65536 - 1000) && (Rotation.Pitch > 32768) )
          {
            SetPrimaryAnimation('Dive',,1.0);
          } else //{
            if ( (bBroomBrake != 0) && (Deceleration < AirSpeedNormal * 0.47999999) )
            {
              SetPrimaryAnimation('Brake',,1.0);
            } else //{
              if ( ((bBroomBoost != 0) || bAuxBoost) && (bBroomBrake == 0) )
              {
                SetPrimaryAnimation('Boost',,1.0);
              } else //{
                if ( Speed < 50 )
                {
                  SetPrimaryAnimation('hover',,0.4);
                } else {
                  SetPrimaryAnimation('Fly_forward',,1.0);
                }
              //}
            //}
          //}
        //}
      //}
    //}
  }
  Trail.ParentBlend = Min(Speed / 200, 1);
}*/

function SetInvincible (bool bOn)
{
  bInvincible = bOn;
}

function SetLookForTarget (Actor NewLookForTarget)
{
  LookForTarget = NewLookForTarget;
  bEasingUpToSpeed = True;
  TickParent = LookForTarget;
}

function SetTargetTrackDist (float fNewTargetTrackDist)
{
  fTargetTrackDist = fNewTargetTrackDist;
}

/*function UpdateBroomSound()
{
  local float fSpeed;
  local float fSpeedFactor;
  local float fTurnFactor;
  local float fVolume;
  local float fPitch;

  fSpeed = VSize(Velocity);
  if ( fSpeed < 50 )
  {
    fVolume = 0.0;
    fPitch = 1.5;
  } else //{
    if ( fSpeed <= AirSpeedNormal )
    {
      fSpeedFactor = (fSpeed - 50) / (AirSpeedNormal - 50);
      fVolume = 0.6 * fSpeedFactor;
      fPitch = 0.2 * fSpeedFactor + 1.5;
    } else {
      fSpeedFactor = (fSpeed - AirSpeedNormal) / (AirSpeedBoost - AirSpeedNormal);
      fVolume = 0.4 * fSpeedFactor + 0.6;
      fPitch = 0.15 * fSpeedFactor + 1.7;
    }
  //}
  if ( Rotation.Roll <= 32768 )
  {
    fTurnFactor = Rotation.Roll / 4096.0;
  } else //{
    if ( Rotation.Roll > 32768 )
    {
      fTurnFactor = (65536.0 - Rotation.Roll) / 4096.0;
    }
  //}
  if ( Rotation.Pitch <= 32768 )
  {
    fTurnFactor += Rotation.Pitch / 8192.0;
  } else //{
    if ( Rotation.Pitch > 32768 )
    {
      fTurnFactor += (65536 - Rotation.Pitch) / 8192.0;
    }
  //}
  fTurnFactor *= 0.5;
  if ( fTurnFactor > 1.0 )
  {
    fTurnFactor = 1.0;
  }
  fVolume *= 1.0 + 2.0 * fTurnFactor;
  fPitch *= 1.0 + 1.0 * fTurnFactor;
  if ( (fTurnFactor > 0.0) && (fTurnFactor < 0.1) )
  {
    if ( fSpeedFactor > 0.69999999 )
    {
      PlayFastWhooshSound();
    } else {
      PlaySlowWhooshSound();
    }
  }
}*/

function InterpolationPoint FindPointOnPath (name Path, optional int PointToFind)
{
  local InterpolationPoint IP;
  local InterpolationPoint FoundIP;

  FoundIP = None;
  foreach AllActors(Class'InterpolationPoint',IP,Path)
  {
    if ( IP.Position == PointToFind )
    {
      FoundIP = IP;
      // goto JL008C;
	  break;
    } else //{
      if ( (PointToFind == 0) && ((FoundIP == None) || (IP.Position < FoundIP.Position)) )
      {
        FoundIP = IP;
      }
    //}
  }
  return FoundIP;
}

function FlyOnPath (name CutScenePath, optional int StartPoint)
{
  local InterpolationPoint I;

  if ( CutScenePath != 'None' )
  {
    I = FindPointOnPath(CutScenePath,StartPoint);
    if ( I != None )
    {
      SetLocation(I.Location);
      SetRotation(I.Rotation);
      SetCollision(True,False,False);
      bCollideWorld = False;
      bInterpolating = True;
      // SetPhysics(0);
	  SetPhysics(PHYS_None);
      IM = Spawn(Class'InterpolationManager',self);
      IM.Init(I.Next,1.0,False);
    }
    if ( IM == None )
    {
      Log("FlyingCar couldn't find path " $ string(CutScenePath));
    }
	else
	{
	  //KW left this empty? -AdamJD
	}
  }
}

function StopFlyingOnPath()
{
  local InterpolationManager IM_ToStop;

  if ( IM != None )
  {
    IM_ToStop = IM;
    IM = None;
    IM_ToStop.FinishedInterpolation(None);
  }
  bCollideWorld = True;
  SetCollision(True,True,True);
  if ( IsInState('FlyingOnPath') )
  {
    GotoState('PlayerWalking');
  }
}

function PlayerTrack (float DeltaTime)
{
  local Vector X;
  local Vector Y;
  local Vector Z;
  local Vector TargetX;
  local Vector TargetY;
  local Vector TargetZ;
  local Vector TargetTrackPoint;
  local float fLastHorzOffset;
  local float fLastVertOffset;
  local Vector TargetDir;
  local float TargetDist;
  local float TargetSpeed;
  local float fDeltaPitch;
  local float CurrentSpeed;
  local Sound Woosh;
  local float fPitch;

  fLastHorzOffset = fTargetTrackHorzOffset;
  
  //////
  if ( bLeftWind && !bRightWind )
  {
	fTargetTrackHorzOffset += ( ( RandRange(fTargetTrackHorzOffset,TrackingOffsetRange_Horz) ) * ( DeltaTime * fWindViolence ) );
  }
  if ( bRightWind && !bLeftWind )
  {
    fTargetTrackHorzOffset += ( ( RandRange(-TrackingOffsetRange_Horz,fTargetTrackHorzOffset) ) * ( DeltaTime * fWindViolence ) );
  }
  
  fTargetTrackHorzOffset += (bBroomYawRight - bBroomYawLeft) * fBroomSensitivityConst * DeltaTime;
  fTargetTrackHorzOffset += aBroomYaw * fBroomSensitivity * TrackingOffsetRange_Horz * ( DeltaTime * FPS_FIX );
  fTargetTrackHorzOffset += aJoyBroomYaw * fJoyBroomSensitivity * fBroomSensitivityConst * DeltaTime;
  if ( fTargetTrackHorzOffset > TrackingOffsetRange_Horz )
  {
    fTargetTrackHorzOffset = TrackingOffsetRange_Horz;
  } else //{
    if ( fTargetTrackHorzOffset <  -TrackingOffsetRange_Horz )
    {
      fTargetTrackHorzOffset =  -TrackingOffsetRange_Horz;
    }
  //}
  fLastVertOffset = fTargetTrackVertOffset;
  fDeltaPitch = (bBroomPitchUp - bBroomPitchDown) * fBroomSensitivityConst * DeltaTime;
  fDeltaPitch -= aBroomPitch * fBroomSensitivity * TrackingOffsetRange_Vert * ( DeltaTime * FPS_FIX );
  fDeltaPitch -= aJoyBroomPitch * fJoyBroomSensitivity * fBroomSensitivityConst * DeltaTime;
  if ( bInvertBroomPitch )
  {
    fDeltaPitch =  -fDeltaPitch;
  }
  fTargetTrackVertOffset += fDeltaPitch;
  if ( fTargetTrackVertOffset > TrackingOffsetRange_Vert )
  {
    fTargetTrackVertOffset = TrackingOffsetRange_Vert;
  } else //{
    if ( fTargetTrackVertOffset <  -TrackingOffsetRange_Vert )
    {
      fTargetTrackVertOffset =  -TrackingOffsetRange_Vert;
    }
  //}
  GetAxes(LookForTarget.Rotation,TargetX,TargetY,TargetZ);
  TargetTrackPoint = LookForTarget.Location + TargetY * fTargetTrackHorzOffset + TargetZ * (fTargetTrackVertOffset - CollisionHeight);
  TargetDir = TargetTrackPoint - Location;
  DesiredRotation = rotator(TargetDir);
  GetAxes(Rotation,X,Y,Z);
  if ( bEasingUpToSpeed )
  {
    AccelRate = 1100.0;
  } else {
    AccelRate = 5000.0;
  }
  Acceleration = AccelRate * X;
  DesiredSpeed = 1.0;
  if ( vDodgeVel != vect(0.00,0.00,0.00) )
  {
    Velocity += vDodgeVel * 175;
    vDodgeVel = vect(0.00,0.00,0.00);
  }
  TargetDist = VSize(TargetDir) - fTargetTrackDist;
  if ( TargetDist > SlowdownRadius )
  {
    AirSpeed = MaxSpeed;
  } else {
    TargetSpeed = VSize(LookForTarget.Velocity);
    AirSpeed = TargetDist / SlowdownRadius * (MaxSpeed - TargetSpeed) + TargetSpeed;
    if ( AirSpeed < 0 )
    {
      AirSpeed = 0.0;
    }
  }
  CurrentSpeed = VSize(Velocity);
  if ( (CurrentSpeed >= 200) || (Abs(CurrentSpeed - AirSpeed) < 75) )
  {
    bEasingUpToSpeed = False;
  }
  /*if ( (Level.TimeSeconds > fNextTimeSafeToWoosh) && (CurrentSpeed > 75) && (((Abs(fTargetTrackHorzOffset - fLastHorzOffset) / DeltaTime) > 150) || ((Abs(fTargetTrackVertOffset - fLastVertOffset) / DeltaTime) > 150)) )
  {
    Woosh = SlowWooshSounds[Rand(NUM_SLOW_WOOSH_SOUNDS)];
    fPitch = RandRange(1.0,1.5);
    PlaySound(Woosh,SLOT_Misc,1.0,,1000.0,fPitch);
    fNextTimeSafeToWoosh = Level.TimeSeconds + ((GetSoundDuration(Woosh) / fPitch) + 0.1);
  }
  UpdateBroomSound();*/
}

function TakeDamage (int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
{
  /*local int EffectiveDamage;

  if ( IsInState('PlayerWalking') )
  {
    StopHeadLook();
    WatchTarget = None;
    PlayAnim('Bump',,0.2);
    bHit = True;
    if ( !(InstigatedBy.IsA('Seeker') && DamageType != 'Kicked') )
    {
      PlaySound(HurtSound[Rand(NUM_HURT_SOUNDS)],SLOT_Talk,,True);
      if ( (DamageType == 'Kicked') || (DamageType == 'Bludgered') )
      {
        if ( Director != None )
        {
          Director.OnTakeDamage(self,Damage,InstigatedBy,DamageType);
        }
      }
	  if ( !bInvincible )
      {
        if ( QuidArmorStatus.GetCount() > 0 )
        {
          EffectiveDamage = (Damage * 0.5) * ArmorDamageScale;
        }
		else
		{
		  EffectiveDamage = Damage * 0.5;
		}
		ClientMessage("BroomHarry Damage=" $ string(Damage) $ ", EffectiveDamage=" $ string(EffectiveDamage));
		AddHealth(-EffectiveDamage);
        if ( GetHealthCount() <= 0.0 )
        {
          KillHarry(True);
        }
      }
    }
  }*/
}

function KillHarry (bool bImmediateDeath)
{
  //ClientMessage("I can't go on!!!!");
  //GotoState('BroomDying');
}

function DoDrinkWiggenwell()
{
  /*if (  !IsInState('PlayerWalking') || bHit || bHitWall )
  {
    return;
  }
  StopHeadLook();
  WatchTarget = None;
  Super.DoDrinkWiggenwell();*/
}

function PlayInAir()
{
}

function PlayWaiting()
{
}

state PlayerWalking
{
  ignores  Mount, AltFire;
  
  function BeginState()
  {
    local BaseCam Camera;
    //local Seeker WatchTarget;
  
    ClientMessage("FlyingCar: Entered " $ string(GetStateName()) $ " State");
    Log("FlyingCar: Entered " $ string(GetStateName()) $ " State");
    Super.BeginState();
    // SetPhysics(4);
	SetPhysics(PHYS_Flying);
    bCollideWorld = True;
    SetCollision(True,True,True);
    if ( Director == None )
    {
      foreach AllActors(Class'BaseCam',Camera)
      {
        // Camera.SetCameraMode(4);
		Camera.SetCameraMode(CM_Quidditch);
        // goto JL009D;
		break;
      }
    }
  }
  
  function EndState()
  {
    ClientMessage("FlyingCar: Exited " $ string(GetStateName()) $ " State");
    Log("FlyingCar: Exited " $ string(GetStateName()) $ " State");
    //WatchTarget = None;
    Super.EndState();
  }
    
  event PlayerTick (float DeltaTime)
  {
    if ( LookForTarget != None )
    {
      PlayerTrack(DeltaTime);
    } else {
      PlayerMove(DeltaTime);
    }
    Destination = Location + (vector(Rotation) * 100);
    DeterminePrimaryAnim();
	ViewShake(DeltaTime);
  }
  
  function PlayerMove (float DeltaTime)
  {
    local Vector X;
    local Vector Y;
    local Vector Z;
    local Vector NewAccel;
    local float DecelRate;
    local float HiDecelRate;
  
    HiDecelRate = 0.2;
    DecelRate = 2.5;
    if ( (Abs(bBroomPitchUp) > 0.0005) || (Abs(bBroomPitchDown) > 0.0005) )
    {
      if ( ePitchControlDevice == DEVICE_Mouse )
      {
        fMousePitch = 0.0;
      }
      // ePitchControlDevice = 0;
	  ePitchControlDevice = DEVICE_Button;
    } else //{
      if ( Abs(aJoyBroomPitch) > 0.0005 )
      {
        if ( ePitchControlDevice == DEVICE_Mouse )
        {
          fMousePitch = 0.0;
        }
        // ePitchControlDevice = 2;
		ePitchControlDevice = DEVICE_Joystick;
      } else //{
        if ( bAllowBroomMouse && (Abs(aBroomPitch) > 0.0005) )
        {
          // ePitchControlDevice = 1;
		  ePitchControlDevice = DEVICE_Mouse;
        }
      //}
    //}
    if ( (Abs(bBroomYawLeft) > 0.0005) || (Abs(bBroomYawRight) > 0.0005) )
    {
      if ( eYawControlDevice == DEVICE_Mouse )
      {
        fMouseYaw = 0.0;
      }
      // eYawControlDevice = 0;
	  eYawControlDevice = DEVICE_Button;
    } else //{
      if ( Abs(aJoyBroomYaw) > 0.0005 )
      {
        if ( eYawControlDevice == DEVICE_Mouse )
        {
          fMouseYaw = 0.0;
        }
        // eYawControlDevice = 2;
		eYawControlDevice = DEVICE_Joystick;
      } else //{
        if ( bAllowBroomMouse && (Abs(aBroomYaw) > 0.0005) )
        {
          // eYawControlDevice = 1;
		  eYawControlDevice = DEVICE_Mouse;
        }
      //}
    //}
    switch (ePitchControlDevice)
    {
      // case 1:
	  case DEVICE_Mouse:
		  if ( bInvertBroomPitch )
		  {
			fMousePitch += aBroomPitch * fBroomSensitivity;
		  } else {
			fMousePitch -= aBroomPitch * fBroomSensitivity;
		  }
		  if ( fMousePitch > 1.5 )
		  {
			fMousePitch = 1.5;
		  } else //{
			if ( fMousePitch < -1.5 )
			{
			  fMousePitch = -1.5;
			}
		  //}
		  break;
      // case 2:
	  case DEVICE_Joystick:
		  if ( bInvertBroomPitch )
		  {
			fPitchControl = aJoyBroomPitch * fJoyBroomSensitivity;
		  } else {
			fPitchControl =  -aJoyBroomPitch * fJoyBroomSensitivity;
		  }
		  break;
      // case 0:
	  case DEVICE_Button:
		  fPitchControl = 1.0 * bBroomPitchUp - 1.0 * bBroomPitchDown;
		  if ( bInvertBroomPitch )
		  {
			fPitchControl =  -fPitchControl;
		  }
		  break;
      default:
		  fPitchControl = 0.0;
		  break;
    }
    switch (eYawControlDevice)
    {
      // case 1:
	  case DEVICE_Mouse:
		  fMouseYaw += aBroomYaw * fBroomSensitivity;
		  if ( Abs(aBroomYaw) > 0.0005 )
		  {
			//KW left this empty? -AdamJD
		  }
		  if ( fMouseYaw > 1.5 )
		  {
			fMouseYaw = 1.5;
		  } else //{
			if ( fMouseYaw < -1.5 )
			{
			  fMouseYaw = -1.5;
			}
		  //}
		  if ( fMouseYaw > 0.5 )
		  {
			fYawControl = fMouseYaw - 0.3;
		  } else //{
			if ( fMouseYaw < -0.5 )
			{
			  fYawControl = fMouseYaw + 0.3;
			} else {
			  fYawControl = 0.0;
			}
		  //}
		  break;
      // case 2:
	  case DEVICE_Joystick:
		  fYawControl = aJoyBroomYaw * fJoyBroomSensitivity;
		  break;
      // case 0:
	  case DEVICE_Button:
		  fYawControl = 1.0 * bBroomYawRight - 1.0 * bBroomYawLeft;
		  break;
      default:
		  fYawControl = 0.0;
		  break;
    }
    UpdateRotation(DeltaTime,1.0);
    GetAxes(Rotation,X,Y,Z);
    Acceleration = 200000.0 * X;
    if ( (bCarBoost != 0 || bAuxBoost) && (bBroomBrake == 0) )
    {
      AirSpeed = AirSpeedBoost;
    } else {
      if ( (Abs(fYawControl) > 0.2) || (bBroomBrake != 0) )
      {
        if ( Deceleration < AirSpeedNormal / 2 )
        {
          Deceleration += ((AirSpeedNormal / 2) / DecelRate) * DeltaTime;
        }
      }
	  else
	  {
		  if ( Deceleration > 0 )
		  {
			if ( Deceleration > 0.4 * AirSpeedNormal )
			{
			  Deceleration -= ((AirSpeedNormal / 2) / HiDecelRate) * DeltaTime;
			}
			else
			{
			  Deceleration -= ((AirSpeedNormal / 2) / DecelRate) * DeltaTime;
			}		
			if ( Deceleration < 0 )
			{
			  Deceleration = 0;
			}
		  }
	  }
      AirSpeed = AirSpeedNormal - Deceleration;
    }
    //UpdateBroomSound();
  }
  
  function UpdateRotation (float DeltaTime, float maxPitch)
  {
    local Rotator NewRotation;
    local float YawVal;
    local float DeltaYaw;
    local int nDeltaYaw;
    local float DeltaPitch;
    local float fPitchLimitHi;
    local float fPitchLimitLo;
    local float fEffectiveMousePitch;
  
    NewRotation = Rotation;
    fPitchLimitHi = PitchLimitUp * (16384 / 90.0);
    fPitchLimitLo = 65536.0 - (PitchLimitDown * (16384 / 90.0));
    switch (ePitchControlDevice)
    {
      // case 1:
	  case DEVICE_Mouse:
		  if ( fMousePitch > 0.15 )
		  {
			fEffectiveMousePitch = fMousePitch - 0.15;
			if ( fEffectiveMousePitch > 1.0 )
			{
			  fEffectiveMousePitch = 1.0;
			}
		  } else //{
			if ( fMousePitch < -0.15 )
			{
			  fEffectiveMousePitch = fMousePitch + 0.15;
			  if ( fEffectiveMousePitch < -1.0 )
			  {
				fEffectiveMousePitch = -1.0;
			  }
			} else {
			  fEffectiveMousePitch = 0.0;
			}
		  //}
		  if ( (fEffectiveMousePitch < 0.0) &&  !bLastPitchNeg )
		  {
			bLastPitchNeg = True;
		  } else //{
			if ( (fEffectiveMousePitch > 0.0) && bLastPitchNeg )
			{
			  bLastPitchNeg = False;
			}
		  //}
		  NewRotation.Pitch = fEffectiveMousePitch * fPitchLimitHi;
		  NewRotation.Pitch = NewRotation.Pitch & 65535;
		  break;
      // case 2:
	  case DEVICE_Joystick:
		  if ( (fPitchControl < 0.0) &&  !bLastPitchNeg )
		  {
			bLastPitchNeg = True;
		  } else //{
			if ( (fPitchControl > 0.0) && bLastPitchNeg )
			{
			  bLastPitchNeg = False;
			}
		  //}
		  NewRotation.Pitch += RotationRate.Pitch * DeltaTime * fPitchControl;
		  NewRotation.Pitch = NewRotation.Pitch & 65535;
		  if ( (NewRotation.Pitch > fPitchLimitHi) && (NewRotation.Pitch < fPitchLimitLo) )
		  {
			if ( fPitchControl > 0 )
			{
			  NewRotation.Pitch = fPitchLimitHi;
			}
			else
			{
			  NewRotation.Pitch = fPitchLimitLo;
			}
		  }
		  break;
      // case 0:
	  case DEVICE_Button:
		  if ( (fPitchControl < 0.0) &&  !bLastPitchNeg )
		  {
			bLastPitchNeg = True;
		  } else //{
			if ( (fPitchControl > 0.0) && bLastPitchNeg )
			{
			  bLastPitchNeg = False;
			}
		  //}
		  if ( Abs(fPitchControl) < 0.05 )
		  {
			if ( Rotation.Pitch >= 32768 )
			{
			  DeltaPitch = 65536.0 - Rotation.Pitch;
			} else {
			  DeltaPitch = Rotation.Pitch;
			}
			fPitchControl = DeltaPitch / (RotationRate.Pitch * DeltaTime);
			if ( fPitchControl > 1.0 )
			{
			  fPitchControl = 1.0;
			}
			if ( Rotation.Pitch < 32768 )
			{
			  fPitchControl =  -fPitchControl;
			}
		  }
		  NewRotation.Pitch += RotationRate.Pitch * DeltaTime * fPitchControl;
		  NewRotation.Pitch = NewRotation.Pitch & 65535;
		  if ( (NewRotation.Pitch > fPitchLimitHi) && (NewRotation.Pitch < fPitchLimitLo) )
		  {
			if ( fPitchControl > 0 )
			{
			  NewRotation.Pitch = fPitchLimitHi;
			}
			else
			{
			  NewRotation.Pitch = fPitchLimitLo;
			}
		  }
		  break;
      default:
    }
    if ( (fYawControl < 0.0) &&  !bLastYawNeg )
    {
      bLastYawNeg = True;
    } else //{
      if ( (fYawControl > 0.0) && bLastYawNeg )
      {
        bLastYawNeg = False;
      }
    //}
    if ( Abs(fYawControl) < 0.0005 )
    {
      if ( bHittingWall )
      {
        fYawControl = WallAvoidanceYaw * fWallAvoidanceRate / (fRotationRateYaw * DeltaTime);
        fLastTimeAvoidedWall = Level.TimeSeconds;
      }
    } else {
      fLastTimeAvoidedWall = -1.0;
    }
    bHittingWall = False;
    if ( fYawControl > 1.0 )
    {
      fYawControl = 1.0;
    } else //{
      if ( fYawControl < -1.0 )
      {
        fYawControl = -1.0;
      }
    //}
    YawVal = fRotationRateYaw * DeltaTime * fYawControl;
    if ( Acceleration == vect(0.00,0.00,0.00) )
    {
      YawVal = 4.0 / 3.0 * YawVal;
    }
    ViewRotation.Yaw += YawVal;
	ViewShake(DeltaTime);
    NewRotation.Yaw = ViewRotation.Yaw;
    SetRotation(NewRotation);
    DesiredRotation = Rotation;
  }
  
    function HitWall (Vector HitNormal, Actor Wall)
  {
    local Vector WallFaceDir;
    local Rotator WallFaceRot;
    local Vector Up;
    local Vector FlightDir;
    local float fSpeed;
    local float fVolume;
    local bool bTurnToRight;
  
    if ( HitNormal.Z < -0.99989998 )
    {
      return;
    }
    if (  !bHitWall )
    {
      bHitWall = True;
      fSpeed = VSize(Velocity);
      fVolume = fSpeed / AirSpeedNormal;
      if (WallDamage > 0 )
	  {
		//KW left this empty? -AdamJD
	  }
      Director.OnHitEvent(self);
    }
    if ( Abs(HitNormal.Z) >= 0.985 )
    {
      return;
    } else {
      fWallAvoidanceRate = 1.0 - (Abs(HitNormal.Z) / 0.985);
    }
    Up.X = 0.0;
    Up.Y = 0.0;
    Up.Z = 1.0;
    WallFaceDir = HitNormal Cross Up;
    WallFaceRot = rotator(WallFaceDir);
    FlightDir = vector(Rotation);
    if ( (fLastTimeAvoidedWall != -1.0) && (Level.TimeSeconds - fLastTimeAvoidedWall < 1.0) )
    {
      bTurnToRight = bLastAvoidanceRight;
    } else {
      bTurnToRight = (FlightDir Dot WallFaceDir) >= 0.0;
      bLastAvoidanceRight = bTurnToRight;
    }
    if ( bTurnToRight )
    {
      WallAvoidanceYaw = (WallFaceRot.Yaw + 1000 - Rotation.Yaw) & 65535;
      if ( WallAvoidanceYaw > 24576 )
      {
        WallAvoidanceYaw = 24576;
      }
    } else {
      WallAvoidanceYaw = (WallFaceRot.Yaw + 32768 - 1000 - Rotation.Yaw) & 65535;
      if ( WallAvoidanceYaw < 40960 )
      {
        WallAvoidanceYaw = 40960;
      }
      WallAvoidanceYaw -= 65536;
    }
    bHittingWall = True;
  }
  
  /*function HitWall (Vector HitNormal, Actor Wall)
  {
    local Vector WallFaceDir;
    local Rotator WallFaceRot;
    local Vector Up;
    local Vector FlightDir;
    local float fSpeed;
    local int EffectiveDamage;
    local float fVolume;
    local bool bTurnToRight;
  
    if ( HitNormal.Z < -0.99989998 )
    {
      return;
    }
    if (  !bHitWall )
    {
      bHitWall = True;
      fSpeed = VSize(Velocity);
      fVolume = fSpeed / AirSpeedNormal;
      //PlaySound(HitSounds[Rand(NUM_HIT_SOUNDS)],SLOT_Interact,fVolume,,,RandRange(0.80,1.20));
      if ( WallDamage > 0 )
      {
        EffectiveDamage = WallDamage * fSpeed / AirSpeedNormal;
		if ( !bInvincible && (EffectiveDamage > 0) )
        {
          PlaySound(HurtSound[Rand(15)],SLOT_Talk,,True);
          AddHealth(-EffectiveDamage);
          if ( GetHealthCount() <= 0.0 )
          {
            KillHarry(True);
          }
        }
      }
      //PlayAnim('Bump',,0.1);
      if ( Director != None )
      {
        Director.OnHitEvent(self);
      }
    }
    if ( Abs(HitNormal.Z) >= 0.985 )
    {
      return;
    } else {
      fWallAvoidanceRate = 1.0 - (Abs(HitNormal.Z) / 0.985); //UTPT forgot to add brackets -AdamJD
    }
    vDodgeVel = GetDodgeVelFromHitwall(self,HitNormal,LookForTarget);
    bHittingWall = True;
  }*/
  
  /*function Bump (Actor Other)
  {
    //local Pawn Target;
	local Pawn pTarget;
  
    pTarget = Pawn(Other);
    if ( !bHit && (!pTarget.IsA('QuidditchPlayer') && !pTarget.IsA('Bludger')) )
    {
      PlayAnim('React');
      if ( pTarget.IsA('QuidGoal') )
      {
        PlaySound(Sound'Q_BRM_HitPole_01',SLOT_Interact,0.69999999,,1000.0,RandRange(0.80,1.20));
      } else {
        PlaySound(HitSounds[Rand(NUM_HIT_SOUNDS)],SLOT_Interact,0.69999999,,1000.0,RandRange(0.80,1.20));
      }
      Velocity = vect(0.00,0.00,1.00);
      bHit = True;
      if ( !bInvincible )
      {
        AddHealth(-WallDamage);
      }
      if ( Director != None )
      {
        Director.OnBumpEvent(self,Other);
      }
    }
  }*/
  
  function AnimEnd()
  {
    if ( PrimaryAnim != 'None' )
    {
      LoopAnim(PrimaryAnim,,2.0);
    }
    if ( SecondaryAnim != 'None' )
    {
      LoopAnim(SecondaryAnim,,2.0);
    }
    bHitWall = False;
    bHit = False;
  }
}

function RestoreVars()
{
	//fBroomSensitivityDividend = SavedfBroomSensitivityDividend;
	fBroomSensitivity = SavedfBroomSensitivityDividend / fBroomSensitivityDivisor;
	fJoyBroomSensitivity = SavedfBroomSensitivityDividend / fJoyBroomSensitivityDivisor;
	fBroomSensitivityConst = SavedfBroomSensitivityConst;
	SetSecondaryAnimation('');
	DeterminePrimaryAnim();
	AmbientSound = CarSound;
	Director.SetCameraToFollowGuide();
	if ( !Director.bPhaseTwo )
	{
		bAllowBoost = True;
	}
}

state stateShock extends PlayerWalking
{
	ignores Mount, AltFire;
		
	event BeginState()
	{	
		//fBroomSensitivityDividend = fBroomSensitivityDividend / 4;
		fBroomSensitivity = (fBroomSensitivityDividend / 4) / fBroomSensitivityDivisor;
		fJoyBroomSensitivity = (fBroomSensitivityDividend / 4) / fJoyBroomSensitivityDivisor;
		fBroomSensitivityConst = fBroomSensitivityConst / 4;
		
		AmbientSound = None;
		
		guide.SplineSpeed = AirSpeedNormal;
		bAllowBoost = False;
		//bTrailEmitting=False;
		Trail.bEmit=False;
		bBoostPlaying = False;
		
		if ( fTargetTrackHorzOffset >= 0 )
		{
			fTargetTrackHorzOffset = RandRange(-10,(-TrackingOffsetRange_Horz / 2));
		}
		else
		{
			fTargetTrackHorzOffset = RandRange(10,(TrackingOffsetRange_Horz / 2));
		}
		
		if ( fTargetTrackVertOffset >= 0 )
		{
			fTargetTrackVertOffset = RandRange(-10,(-TrackingOffsetRange_Vert / 2));
		}
		else
		{
			fTargetTrackVertOffset = RandRange(10,(TrackingOffsetRange_Vert / 2));
		}
	}
	
	event EndState()
	{
		//RestoreVars();
		SetSecondaryAnimation('');
		DeterminePrimaryAnim();
		fBroomSensitivity = SavedfBroomSensitivityDividend / fBroomSensitivityDivisor;
		fJoyBroomSensitivity = SavedfBroomSensitivityDividend / fJoyBroomSensitivityDivisor;
		fBroomSensitivityConst = SavedfBroomSensitivityConst;
		AmbientSound = CarSound;
		Director.SetCameraToFollowGuide();
		if ( !Director.bPhaseTwo )
		{
			bAllowBoost = True;
		}
		GotoState('PlayerWalking');
	}
	
	begin:
		PlayShockedSound();
		SetSecondaryAnimation('flyingeratic',50,2.0);
		Sleep(100 / 50);
		EndState();
}

function PlayShockedSound()
{
	if ( FRand() > 0.25 )
	{
		PlaySound(Sound'Anglia_stalling',SLOT_Pain);
	}
	else
	{
		PlaySound(Sound'ExtendedAdvFC_Sounds.Honk_SFX',SLOT_Pain);
	}
}

/*state stateWind extends PlayerWalking
{
	ignores Mount, AltFire;
		
	event BeginState()
	{	
		SetSecondaryAnimation('flyingeratic',,2.0);
	}
	
	event EndState()
	{
		SetSecondaryAnimation('');
		SetPrimaryAnimation('Flying',,2.0);
		Director.SetCameraToFollowGuide();
	}
	begin:
}*/

function Vector GetDodgeVelFromHitwall (Actor aSelf, Vector vHitNormal, Actor LFT)
{
  local Vector vVel;
  local Vector V;

  if ( LFT.IsA('Snitch') )
  {
    V = Snitch(LFT).GetTargetVector(aSelf.Location,300.0);
  } else {
    V = LFT.Location;
  }
  V = Normal(V - aSelf.Location);
  vVel = (V + vHitNormal * 0.8) / 2;
  if ( vVel.Z > 0 )
  {
    vVel.Z = Abs(vVel.X) + (Abs(vVel.Y) / 2); //UTPT forgot to add brackets -AdamJD
  } else {
    vVel.Z =  -Abs(vVel.X) + (Abs(vVel.Y) / 2); //UTPT forgot to add brackets -AdamJD
  }
  vVel = Normal(vVel);
  return vVel;
}

state stateCutIdle
{
  ignores  Mount, AltFire;
  
  function BeginState()
  {
    ClientMessage("FlyingCar: Entered " $ string(GetStateName()) $ " State");
    Log("FlyingCar: Entered " $ string(GetStateName()) $ " State");
    AirSpeed = 0.0;
  }
  
  event PlayerTick (float DeltaTime)
  {
    Super.PlayerTick(DeltaTime);
    DeterminePrimaryAnim();
    //UpdateBroomSound();
  }
  
  function AnimEnd()
  {
    if ( PrimaryAnim != 'None' )
    {
      LoopAnim(PrimaryAnim,,2.0);
    }
    if ( SecondaryAnim != 'None' )
    {
      LoopAnim(SecondaryAnim,,2.0);
    }
  }
  
}

state FlyingOnPath
{
  ignores  Mount, AltFire;
  
  function BeginState()
  {
    ClientMessage("FlyingCar: Entered " $ string(GetStateName()) $ " State");
    Log("FlyingCar: Entered " $ string(GetStateName()) $ " State");
  }
  
  event PlayerTick (float DeltaTime)
  {
    Super.PlayerTick(DeltaTime);
    ViewRotation = Rotation;
    DeterminePrimaryAnim();
    //UpdateBroomSound();
  }
  
  function AnimEnd()
  {
    if ( PrimaryAnim != 'None' )
    {
      LoopAnim(PrimaryAnim,,2.0);
    }
    if ( SecondaryAnim != 'None' )
    {
      LoopAnim(SecondaryAnim,,2.0);
    }
  }
  
  event FinishedInterpolation (InterpolationPoint Other)
  {
    if ( IM != None )
    {
      IM = None;
      if ( CutCommandCue != "" )
      {
        CutCue(CutCommandCue);
        CutCommandCue = "";
        GotoState('stateCutIdle');
      }
    }
  }
  
}

state Pursue
{
  ignores  Mount, AltFire;
  
  function BeginState()
  {
    ClientMessage("FlyingCar: Entered " $ string(GetStateName()) $ " State");
    Log("FlyingCar: Entered " $ string(GetStateName()) $ " State");
  }
  
  event PlayerTick (float DeltaTime)
  {
    local Vector TargetDir;
    local Vector X;
    local Vector Y;
    local Vector Z;
  
    Super.PlayerTick(DeltaTime);
    if ( (LookForTarget == None) /*|| LookForTarget.bHidden*/ )
    {
      GotoState('PlayerWalking'); 
    }
    TargetDir = LookForTarget.Location - Location;
    DesiredRotation = rotator(TargetDir);
    GetAxes(Rotation,X,Y,Z);
    Acceleration = 200000.0 * X;
    if ( VSize(TargetDir) < 150.0 )
    {
      AirSpeed = VSize(LookForTarget.Velocity) * 1.0;
    } else //{
      if ( VSize(TargetDir) < 300.0 )
      {
        AirSpeed = VSize(LookForTarget.Velocity) * 1.25;
      } else {
        AirSpeed = VSize(LookForTarget.Velocity) * 1.89999998;
      }
    //}
    DesiredSpeed = AirSpeed;
    ViewRotation = Rotation;
    DeterminePrimaryAnim();
    //UpdateBroomSound();
  }
  
  function EndState()
  {
    ClientMessage("FlyingCar: End Pursue");
    Log("FlyingCar: End Pursue");
  }
  
}

/*state Hit
{
  ignores  Mount, AltFire;
  
  function BeginState()
  {
    ClientMessage("BroomHarry: Entered " $ string(GetStateName()) $ " State");
    Log("BroomHarry: Entered " $ string(GetStateName()) $ " State");
  }
  
  event PlayerTick (float DeltaTime)
  {
    Super.PlayerTick(DeltaTime);
    UpdateBroomSound();
  }
  
begin:
  PlayAnim('Bump');
  FinishAnim();
  bHitWall = False;
  GotoState('PlayerWalking');
}*/

/*state BroomDying
{
  ignores  Mount, AltFire;
  
  function BeginState()
  {
    ClientMessage("BroomHarry: Entered " $ string(GetStateName()) $ " State");
    Log("BroomHarry: Entered " $ string(GetStateName()) $ " State");
  }
  
  event PlayerTick (float DeltaTime)
  {
    Super.PlayerTick(DeltaTime);
    UpdateBroomSound();
  }
  
  function Landed (Vector HitNormal)
  {
    Director.OnPlayersDeath();
    SetTimer(0.0,False);
  }
  
  function Timer()
  {
    Director.OnPlayersDeath();
  }
  
  function AnimEnd()
  {
  }
  
begin:
  PlayAnim('Fall');
  FinishAnim();
  Director.OnPlayerDying();
  LoopAnim('Hang');
  // SetPhysics(2);
  SetPhysics(PHYS_Falling);
  SetTimer(10.0,False);
loop:
  Sleep(0.1);
  goto ('Loop');
}*/

defaultproperties
{
    bHideHealth=True
	
	AirSpeedNormal=450

    AirSpeedBoost=750
	
	//AirSpeedBrake=150

    PitchLimitUp=60

    PitchLimitDown=60

    //WallDamage=5

    // BroomHarry:100
	TrackingOffsetRange_Horz=120.00

    // BroomHarry:75
	TrackingOffsetRange_Vert=80.00
	
	fTargetTrackDist=200.0

    ShadowClass=None

    MaxMountHeight=0.00

    Mesh=SkeletalMesh'HPModels.skFordFlyingMesh'
	
	CollideType=CT_Box

    CollisionRadius=30.00

    CollisionHeight=10.00
	
	CollisionWidth=10.00

    //bAlignBottomAlways=True

    RotationRate=(Pitch=24000,Yaw=50000,Roll=6000)
	
	MaxSpeed=1050
	
	SlowdownRadius=50
	
	DrawScale=0.25
	
	CarSound=Sound'Anglia_running2'
	
	BoostSound=Sound'ExtendedAdvFC_Sounds.Boost_SFX'
	
	BoostExpireTime=3.0
	
	BoostRechargeTime=6.0
	
	CarHealth=100
}
