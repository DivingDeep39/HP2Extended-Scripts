//================================================================================
// firecrabSmall.
//================================================================================

class firecrabSmall extends firecrab;

const BOOL_DEBUG_AI= true;
// DD39: Removed and replaced with bCanStrafe.
//var() bool bMoveAround;
var spellFireSmall smallSpell;
var Vector vTemp;
var Vector vTemp2;
var Rotator rotationChange;
var float NormalSpeed;
var() float strafeSpeed;
var() float timeBetweenShots;
var() float fIncreaseHitTimeDistance;
var() float fHitTimeIncrement;
var() int iAccuracyMin;
var() int iAccuracyMax;
var() bool bPlayRoar;
var() float SpellDamage;
var() int iNumShotsBetweenPreAttack;
var int iNumShots;
var() bool bCanStrafe;
var bool StrafeLeft;

function bool HandleSpellFlipendo (optional baseSpell spell, optional Vector vHitLocation)
{
  Super.HandleSpellFlipendo(spell,vHitLocation);
  if (  !IsInState('stayFlipped') )
  {
    GotoState('stateHitBySpell');
  } else //{
    if ( CheckStayFlipped() == False )
    {
      cm("CheckStayFlipped is false. Restore collision radius");
      SetCollisionSize(Default.CollisionRadius * DrawScale / Default.DrawScale,Default.CollisionHeight * DrawScale / Default.DrawScale);
      GotoState('stateHitBySpell');
    }
  //}
  return True;
}

function bool HandleSpellRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
  local Vector V;

  Super.HandleSpellRictusempra(spell,vHitLocation);
  if (  !IsInState('stayFlipped') )
  {
    GotoState('stateHitBySpell');
  } else //{
    if ( CheckStayFlipped() == False )
    {
      SetCollisionSize(Default.CollisionRadius * DrawScale / Default.DrawScale,Default.CollisionHeight * DrawScale / Default.DrawScale);
      GotoState('stateHitBySpell');
    }
  //}
  return True;
}

function bool CheckStayFlipped()
{
  local bool bFlipped;

  bFlipped = False;
  if ( OnALedge(Location) )
  {
    bFlipped = True;
  }
  return bFlipped;
}

function Tick (float DeltaTime)
{
  Super.Tick(DeltaTime);
  if (  !IsInState('AttackHarry') &&  !IsInState('throwing') &&  !IsInState('CutIdle') &&  !IsInState('stateHitBySpell') &&  !IsInState('DoFlip') &&  !IsInState('strafeAround') &&  !IsInState('stayFlipped') )
  {
    TimeUntilNextFire -= DeltaTime;
    if ( TimeUntilNextFire < 0 )
    {
      //DD39: Added "&& !PlayerHarry.bIsCaptured && !PlayerHarry.bKeepStationary && !PlayerHarry.IsInState('CelebrateCardSet')"
	  if ( (VSize(PlayerHarry.Location - Location) < fAttackRange) && PlayerCanSeeMe() && !PlayerHarry.bIsCaptured && !PlayerHarry.bKeepStationary && !PlayerHarry.IsInState('CelebrateCardSet') )
      {
        TimeUntilNextFire = TimeUntilNextFireDefault;
        GotoState('AttackHarry');
      } else {
        TimeUntilNextFire = 2.0;
      }
    }
  }
}

function PlayRoarSound()
{
  local int randNum;

  randNum = Rand(4);
  switch (randNum)
  {
    case 0:
    RoarSound = Sound'firecrab_roar';
    break;
    case 1:
    RoarSound = Sound'firecrab_roar_A';
    break;
    case 2:
    RoarSound = Sound'firecrab_roar_B';
    break;
    case 3:
    RoarSound = Sound'firecrab_roar_C';
    break;
    default:
  }
  PlaySound(RoarSound,SLOT_None,RandRange(0.6,1.0),,10000.0,RandRange(0.80,1.20),,False);
}

state stateHitBySpell
{
  function BeginState()
  {
    AmbientSound = None;
  }
  
 begin:
  if ( BOOL_DEBUG_AI )
  {
    PlayerHarry.ClientMessage(string(Name) $ " : State stateHitBySpell ");
  }
  if (  --iNumSpellHitsToFlip <= 0 )
  {
    if ( (AnimSequence == 'flip2back') || (AnimSequence == 'onback') )
    {
      if ( fTimeOnBack < 5 )
      {
        fTimeOnBack = 5.0;
      }
    } else {
      Acceleration = vect(0.00,0.00,0.00);
      Velocity = vect(0.00,0.00,0.00);
    }
    GotoState('DoFlip');
  } else {
    Velocity = vect(0.00,0.00,0.00);
    Acceleration = vect(0.00,0.00,0.00);
    PlayAnim('KnockBack');
    FinishAnim();
    PlayAnim('Look');
    FinishAnim();
    TimeUntilNextFire = TimeUntilNextFire + 1.0;
	// DD39: Cleared because other function sets it.
    //AmbientSound = WalkingSound;
	// DD39: Check if it's actually set to patrol.
    if ( firstPatrolPointObjectName != '' )
    {
	  SetWalkingSound();
	  GotoState('patrol');
    } else {
      TurnTo(Location + vMoveDir);
      // DD39: Set in parent.
      //vMoveDirRot = Rotation;
      //vMoveDir = vector(vMoveDirRot);
      // DD39: Cleared bcs no idea what it does.
      //TurnTo(navP.Location);
      // DD39: Cleared because other function sets it.
      //AmbientSound = WalkingSound;
      SetWalkingSound();
      GotoState('patrol');
    }
  }
}

state DoFlip
{
  function BeginState()
  {
    playHitSound();
  }
  
  function Tick (float DeltaTime)
  {
    Super.Tick(DeltaTime);
    if ( VSize(Velocity) <= 5 )
    {
      if ( OnALedge(Location) )
      {
        vPush = pushDirection();
        SetCollisionSize(CollisionRadius - 10,CollisionHeight);
        GotoState('FallOverLedge');
      } else {
        fFlipPushForceXY = Default.fFlipPushForceXY;
        fFlipPushForceZ = Default.fFlipPushForceZ;
      }
    }
  }
  
 begin:
  if ( BOOL_DEBUG_AI )
  {
    PlayerHarry.ClientMessage(string(Name) $ " : State Do Flip ");
  }
  fHighestZ = Location.Z;
  // eVulnerableToSpell = 13;
  eVulnerableToSpell = SPELL_Flipendo;
  PlayAnim('flip2back');
  Sleep(1.0);
  // if ( bool(Physics) != bool(2) )
  if(Physics != PHYS_Falling)
  {
    PlaySound(Sound'SPI_large_LandOnBack',SLOT_None,RandRange(0.89999998,1.0),,200000.0,RandRange(0.80,1.20),,False);
  }
  Sleep(1.0);
  LoopAnim('onback');
  Sleep(fTimeOnBack);
  LoopAnim('recover');
  Sleep(1.0);
  playFlipSound();
  // eVulnerableToSpell = 22;
  eVulnerableToSpell = SPELL_Rictusempra;
  Sleep(1.1);
  // if ( bool(Physics) != bool(2) )
  if(Physics != PHYS_Falling)
  {
    PlaySound(Sound'SPI_large_LandOnBack',SLOT_None,RandRange(0.89999998,1.0),,200000.0,RandRange(0.80,1.20),,False);
  }
  Sleep(0.5);
  LoopAnim('Look');
  FinishAnim();
  LoopAnim('Idle');
  TimeUntilNextFire = TimeUntilNextFire + 1.0;
  // DD39: Cleared because other function sets it.
  //AmbientSound = WalkingSound;
  fTimeOnBack = fTimeSpentOnBack;
  // DD39: Check if it's actually set to patrol.
  if ( firstPatrolPointObjectName != '' )
  {
	SetWalkingSound();
	GotoState('patrol');
  } else {
  TurnTo(Location + vMoveDir);
  // DD39: Set in parent.
  //vMoveDirRot = Rotation;
  //vMoveDir = vector(vMoveDirRot);
  // DD39: Cleared bcs no idea what it does.
  //TurnTo(navP.Location);
  // DD39: Cleared because other function sets it.
  //AmbientSound = WalkingSound;
  SetWalkingSound();
  GotoState('patrol');
  }
}

state AttackHarry
{
  function Tick (float DeltaTime)
  {
	// DD39: Follow Harry.
	DesiredRotation.Yaw = rotator(playerHarry.Location - Location).Yaw;
  }
  
 begin:
  if ( BOOL_DEBUG_AI )
  {
    PlayerHarry.ClientMessage("" $ string(Name) $ ": attackHarry");
  }
  LoopAnim('Idle');
  Velocity = vect(0.00,0.00,0.00);
  Acceleration = vect(0.00,0.00,0.00);
  AmbientSound = None;
  if ( bPlayRoar == True )
  {
    // DD39:
	//TurnTo(PlayerHarry.Location);
    PlayRoarSound();
    PlayAnim('roar');
    FinishAnim();
  }
  
 wait:
  // DD39: Disable the following.
  Disable('tick');
  //TurnTo(Location + Location - PlayerHarry.Location);
  Velocity = vect(0.00,0.00,0.00);
  Acceleration = vect(0.00,0.00,0.00);
  TurnTo(Location + Location - PlayerHarry.Location);
  Sleep(0.05);
  // DD39: If Harry's in light of sight, go to throwing, otherwise patrol.
  if ( LineOfSightTo(PlayerHarry) )
  {
	GotoState('throwing');
  }
  else
  {
    // DD39: Check if it's actually set to patrol.
    if ( firstPatrolPointObjectName != '' )
	{
		GotoState('patrol');
	} else {
	  TurnTo(Location + vMoveDir);
	  // DD39: Set in parent.
	  //vMoveDirRot = Rotation;
	  //vMoveDir = vector(vMoveDirRot);
	  // DD39: Cleared bcs no idea what it does.
	  //TurnTo(navP.Location);
	  // DD39: Cleared because other function sets it.
      //AmbientSound = WalkingSound;
	  SetWalkingSound();
	  GotoState('patrol');
	}
  }
  goto ('Wait');
}

state throwing
{
  function BeginState()
  {
    iNumShots = iNumShotsBetweenPreAttack;
  }
  
  function Tick (float DeltaTime)
  {
  }
  
  function Touch (Actor Other)
  {
    if ( Other.bBlockActors )
    {
      HitWall(Normal(Location - Other.Location),Other);
    }
  }
  
  function HitWall (Vector HitNormal, Actor Wall)
  {
    SetLocation(OldLocation);
    Velocity = MirrorVectorByNormal(Velocity,HitNormal);
  }
  
 begin:
  // DD39: Added Acceleration and Velocity.
  Velocity = vect(0.00,0.00,0.00);
  Acceleration = vect(0.00,0.00,0.00);
  PlaySound(Sound'firecrab_preattack',SLOT_None);
  PlayAnim('preattack');
  FinishAnim();
  // if ( LineOfSightTo(PlayerHarry) && (iNumShots > 0) )
  while ( LineOfSightTo(PlayerHarry) && (iNumShots > 0) )
  {
    iNumShots--;
    TurnTo(Location + (Location - PlayerHarry.Location));
    Target = PlayerHarry;
    SetRotation(Rotation + rot(0,32768,0));
    smallSpell = spellFireSmall(SpawnSpell(Class'spellFireSmall',PlayerHarry));
    smallSpell.iDamage = SpellDamage;
	smallSpell.fIncreaseHitTimeDistance = fIncreaseHitTimeDistance;
    smallSpell.fHitTimeIncrement = fHitTimeIncrement;
    smallSpell.iAccuracyMin = iAccuracyMin;
    smallSpell.iAccuracyMax = iAccuracyMax;
    SetRotation(Rotation + rot(0,32768,0));
    PlaySound(AttackSound,SLOT_None);
    PlayAnim('Attack');
    FinishAnim();
	// DD39: Replaced " ( bMoveAround == True ) " with " bCanStrafe".
    if (  !LineOfSightTo(PlayerHarry) && bCanStrafe )
    {
      TurnTo(Location + (Location - PlayerHarry.Location));
      vTemp = Normal(PlayerHarry.Location - Location);
      vTemp2 = Location Cross PlayerHarry.Location;
      if ( BOOL_DEBUG_AI )
      {
        PlayerHarry.ClientMessage("cross = " $ string(vTemp2));
      }
      if ( vTemp2.Z > 0 )
      {
        LoopAnim('StrafeLeft');
        vTemp2 =  -(vTemp Cross Vec(0.0,0.0,1.0));
        if ( BOOL_DEBUG_AI )
        {
          PlayerHarry.ClientMessage("strafing left");
        }
      } else //{
        if ( vTemp2.Z < 0 )
        {
          LoopAnim('StrafeRight');
          vTemp2 = vTemp Cross Vec(0.0,0.0,1.0);
          if ( BOOL_DEBUG_AI )
          {
            PlayerHarry.ClientMessage("strafing right");
          }
        } else {
          LoopAnim('Walk');
          vTemp2 = Normal(Location - PlayerHarry.Location);
          if ( BOOL_DEBUG_AI )
          {
            PlayerHarry.ClientMessage("backing up");
          }
        }
      //}
      Acceleration = vTemp2;
      Velocity = GroundSpeed * vTemp2;
      Sleep(1.5);
    }
    Sleep(timeBetweenShots);
    // goto JL0015;
  }
  if ( iNumShots <= 0 )
  {
    // DD39: Added additional check.
	if ( bCanStrafe )
	{
	  GotoState('strafeAround');
	} else {
	  if ( VSize(PlayerHarry.Location - Location) < fAttackRange )
      {
        iNumShots = iNumShotsBetweenPreAttack;
        Goto('begin');
	  } else {
	    Sleep(0.8);
		// DD39: Check if it's actually set to patrol.
		if ( firstPatrolPointObjectName != '' )
		{
			SetWalkingSound();
			GotoState('patrol');
		} else {
          TurnTo(Location + vMoveDir);
		  // DD39: Set in parent.
          //vMoveDirRot = Rotation;
          //vMoveDir = vector(vMoveDirRot);
		  // DD39: Cleared bcs no idea what it does.
          //TurnTo(navP.Location);
          // DD39: Cleared because other function sets it.
		  //AmbientSound = WalkingSound;
		  SetWalkingSound();
          GotoState('patrol');
	    }
      }
	}
  } else {
    Sleep(0.8);
	// DD39: Check if it's actually set to patrol.
    if ( firstPatrolPointObjectName != '' )
	{
		SetWalkingSound();
		GotoState('patrol');
	} else {
      TurnTo(Location + vMoveDir);
	  // DD39: Set in parent.
      //vMoveDirRot = Rotation;
      //vMoveDir = vector(vMoveDirRot);
	  // DD39: Cleared bcs no idea what it does.
      //TurnTo(navP.Location);
      // DD39: Cleared because other function sets it.
      //AmbientSound = WalkingSound;
	  SetWalkingSound();
      GotoState('patrol');
    }
  }
}

state strafeAround
{
  function BeginState()
  {
    NormalSpeed = GroundSpeed;
    GroundSpeed = strafeSpeed;
  }
  
  function EndState()
  {
    GroundSpeed = NormalSpeed;
  }
  
 begin:
 // DD39: Removed because added check in state throwing.
  //if ( bCanStrafe == True )
  //{
    TurnTo(Location + Location - PlayerHarry.Location);
    vTemp = Normal(PlayerHarry.Location - Location);
    vTemp2 = Location Cross PlayerHarry.Location;
    if ( BOOL_DEBUG_AI )
    {
      PlayerHarry.ClientMessage("cross = " $ string(vTemp2));
    }
    if ( StrafeLeft == True )
    {
      if ( BOOL_DEBUG_AI )
      {
        PlayerHarry.ClientMessage("strafing left");
      }
      StrafeLeft = False;
      vTemp2 =  -(vTemp Cross Vec(0.0,0.0,1.0));
      rotationChange = rotator(vTemp2);
      rotationChange.Yaw -= 4000;
      vTemp2 = vector(rotationChange);
      LoopAnim('StrafeLeft',2.0);
    } else //{
      if ( StrafeLeft == False )
      {
        if ( BOOL_DEBUG_AI )
        {
          PlayerHarry.ClientMessage("strafing right");
        }
        StrafeLeft = True;
        vTemp2 = vTemp Cross Vec(0.0,0.0,1.0);
        rotationChange = rotator(vTemp2);
        rotationChange.Yaw += 4000;
        vTemp2 = vector(rotationChange);
        LoopAnim('StrafeRight',2.0);
      } else {
        GotoState('throwing');
      }
    //}
    Acceleration = vTemp2;
    Velocity = GroundSpeed * vTemp2;
    Sleep(0.64999998);
    Velocity = vect(0.00,0.00,0.00);
    Acceleration = vect(0.00,0.00,0.00);
    TurnTo(Location + Location - PlayerHarry.Location);
  //}
  if ( VSize(PlayerHarry.Location - Location) < fAttackRange )
  {
    TurnTo(Location + Location - PlayerHarry.Location);
    GotoState('throwing');
  } else {
    Sleep(0.3);
    // DD39: Check if it's actually set to patrol.
    if ( firstPatrolPointObjectName != '' )
	{
		SetWalkingSound();
		GotoState('patrol');
	} else {
      TurnTo(Location + vMoveDir);
	  // DD39: Set in parent.
      //vMoveDirRot = Rotation;
      //vMoveDir = vector(vMoveDirRot);
	  // DD39: Cleared bcs no idea what it does.
      //TurnTo(navP.Location);
      // DD39: Cleared because other function sets it.
      //AmbientSound = WalkingSound;
	  SetWalkingSound();
      GotoState('patrol');
    }
  }
}

defaultproperties
{
    // DD39: Removed.
	//bMoveAround=True

    NormalSpeed=100.00

    strafeSpeed=150.00

    timeBetweenShots=0.20

    fIncreaseHitTimeDistance=200.00

    fHitTimeIncrement=0.50

    iAccuracyMax=10

    bPlayRoar=True

    SpellDamage=5.00

    iNumShotsBetweenPreAttack=2

    bCanStrafe=True

    WalkingSound=Sound'HPSounds.Critters_sfx.firecrab_walk'

    iNumSpellHitsToFlipDefault=1

    bFlipPushable=True

    soundFalling(0)=Sound'HPSounds.Critters_sfx.firecrab_falling'

    soundFalling(1)=Sound'HPSounds.Critters_sfx.firecrab_falling_A'

    lockSpell=True

    MultiSkins(1)=WetTexture'HPParticle.hp_fx.General.GemWet'

    SoundRadius=25

    CollisionRadius=30.00

}
