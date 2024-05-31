//================================================================================
// CornishPixie.
//================================================================================

class CornishPixie extends HChar;

const BOOL_DEBUG_AI= false;
var Vector vHome;
var Vector vOriginalHome;
var Vector vTargetDir;
var Rotator rHitRotation;
var float DistanceHome;
var(VisualFX) ParticleFX fxFlyParticleEffect;
var(VisualFX) Class<ParticleFX> fxFlyParticleEffectClass;
var ParticleFX fxBlowUp;
var ParticleFX fxHit;
var baseWand wand;
var Sound pixieLoopSound;
var Vector vTemp;
var CornishPixie myFriends[3];
var int numFriends;
var int Counter;
var bool bAttacking;
var Vector vHarryAttackPosition;
var float randomTalk;
var() int numAttacksDefault;
var int numAttacks;
var() float fDamageAmount;
var() name GroupName;
var() float timeStunned;
var bool bStunned;
var() float encroachRadius;
var() name patrolPointTag;
var() bool waitForTrigger;
var() bool goToPatrolPoint;
var PatrolPoint pP;
var() float StayOnSplineDefault;
var float StayOnSpline;
var() float StopAttackDistance;
//DD39: bCapturable = Pixie idles when a cutscene starts
var() bool bCapturable;
//DD39: bDontBlockInAttack: Pixie won't block Harry during attacks (Adv11b fix)
var() bool bDontBlockInAttack;
//DD39: bHoldOff = bool to not attack Harry in certain situations
var bool bHoldOff;
//DD39: bFXSpawned = bool to signal when ambient sounds and emitter need to spawn
var bool bFXSpawned;
//DD39: bTriggered = bool for when Pixie is triggered
var bool bTriggered;
//DD39: bCollOff = bool for when collision is disabled
var bool bCollOff;

function PreBeginPlay()
{
  Super.PreBeginPlay();
  vHome = Location;
  vOriginalHome = Location;
  lockSpell = True;
  LoopAnim('Idle');
}

function PostBeginPlay()
{
  local CornishPixie tempPixie;
  local PixieMarker Marker;

  Super.PostBeginPlay();
  if ( DrawScale != Default.DrawScale )
  {
    SetCollisionSize(Default.CollisionRadius * DrawScale / Default.DrawScale,Default.CollisionHeight * DrawScale / Default.DrawScale);
  }
  numAttacks = numAttacksDefault;
  SetCollision(True,False,True);
  foreach AllActors(Class'CornishPixie',tempPixie)
  {
    if ( tempPixie != self )
    {
      if ( tempPixie.GroupName == GroupName )
      {
        myFriends[numFriends] = tempPixie;
        numFriends++;
      }
    }
  }
}

function PlayerCutCapture()
{
	//DD39: If dying or waiting for trigger, ignore
	if ( bStunned || IsInState('stateDying') || waitForTrigger )
	{
	  return;
	}
	//DD39: Hold Off from attacking
    bHoldOff = True;
	//DD39: Added Collision Check
	if ( !bCollOff )
	{
	  //DD39: Disable collision so they can fly through you
	  SetCollision(True,False,False);
	  //DD39: Collision check is enabled
	  bCollOff = True;
	}
	//DD39: If capturable or not
	if ( bCapturable && !bStunned && !IsInState('stateDying') )
	{
      GotoState('CutIdle');
    } else {
	  if ( !IsInState('stateLoopSplinePath') && !IsInState('stateRunAway') && !IsInState('stateHitByRictusempra') && !IsInState('Triggered') )
	  {
		LoopAnim('Fly');
		GotoState('stateLoopSplinePath');
	  }
	}
}

state CutIdle
{
begin:
  Acceleration = vect(0.00,0.00,0.00);
  Velocity = vect(0.00,0.00,0.00);
  GotoState('waitingForTrigger');
}

function PlayerCutRelease()
{
  //DD39: if dying or waiting for trigger, ignore
  if ( bStunned || IsInState('stateDying') || waitForTrigger )
  {
    return;
  }
  //DD39: time everyone's sighting
  StayOnSpline = StayOnSplineDefault;
  if ( bCapturable && !bStunned && !IsInState('stateDying') )
  {
	LoopAnim('Fly');
    GotoState('stateLoopSplinePath');
  }
}

function Timer()
{
  GotoState('BlowUpAndDie');
}

function bool HandleSpellRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
  Super.HandleSpellRictusempra(spell,vHitLocation);
  //DD39: moved part of stateHitByRictusempra in here to split the state in two
  DestroyControllers();
  PlaySound(Sound'SPI_hit',SLOT_None,RandRange(0.89999998,1.0),,2000.0,RandRange(1.60,2.20),,False);
  if (  --numAttacks <= 0 )
  {
    bStunned = True;
	GotoState('stateDying');
  } else {
    Velocity = vect(0.00,0.00,0.00);
    Acceleration = vect(0.00,0.00,0.00);
    GotoState('stateHitByRictusempra');
  }
  return True;
}

function Landed (Vector HitNormal)
{
  if ( BOOL_DEBUG_AI )
  {
    PlayerHarry.ClientMessage("" $ string(Name) $ ": In function Landed");
  }
  SetTimer(0.0,False);
  Super.Landed(HitNormal);
  GotoState('HitGround');
}

function bool GoAfterHarry()
{
  local bool bRet;
  local Vector vVectorToHarry;

  bRet = False;
  vVectorToHarry = PlayerHarry.Location - Location;
  //DD39: make your checks
  if ( VSize(vVectorToHarry) < SightRadius && !bHoldOff && !PlayerHarry.bIsCaptured && !PlayerHarry.bKeepStationary && !PlayerHarry.IsInState('CelebrateCardSet') && PlayerCanSeeMe() )
  {
    bRet = True;
  }
  return bRet;
}

function playTalkSound()
{
  local Sound talkSound;
  local int randNum;

  randNum = Rand(6);
  switch (randNum)
  {
    case 0:
    talkSound = Sound'PIX_talk_01';
    break;
    case 1:
    talkSound = Sound'PIX_talk_02';
    break;
    case 2:
    talkSound = Sound'PIX_talk_03';
    break;
    case 3:
    talkSound = Sound'PIX_talk_04';
    break;
    case 4:
    talkSound = Sound'PIX_talk_05';
    break;
    case 5:
    talkSound = Sound'PIX_talk_06';
    break;
    default:
    talkSound = Sound'PIX_talk_06';
    break;
  }
  //DD39: don't talk while in cutscenes
  if ( !PlayerHarry.bIsCaptured )
  {
    PlaySound(talkSound,SLOT_None,RandRange(0.8,1.0),,1000.0,RandRange(0.80,1.20),,False);
  }
}

function playAttackSound()
{
  local Sound AttackSound;
  local int randNum;

  randNum = Rand(5);
  switch (randNum)
  {
    case 0:
    AttackSound = Sound'PIX_attack_01';
    break;
    case 1:
    AttackSound = Sound'PIX_attack_02';
    break;
    case 2:
    AttackSound = Sound'PIX_attack_03';
    break;
    case 3:
    AttackSound = Sound'PIX_attack_04';
    break;
    case 4:
    AttackSound = Sound'PIX_attack_05';
    break;
    default:
    AttackSound = Sound'PIX_attack_05';
    break;
  }
  PlaySound(AttackSound,SLOT_None,RandRange(0.6,1.0),,10000.0,RandRange(0.80,1.20),,False);
}

function playHitSound()
{
  local Sound HitSound;
  local int randNum;

  randNum = Rand(6);
  switch (randNum)
  {
    case 0:
    HitSound = Sound'pixie_ouch1';
    break;
    case 1:
    HitSound = Sound'pixie_ouch2';
    break;
    case 2:
    HitSound = Sound'pixie_ouch3';
    break;
    case 3:
    HitSound = Sound'pixie_ouch4';
    break;
    case 4:
    HitSound = Sound'pixie_ouch5';
    break;
    case 5:
    HitSound = Sound'pixie_ouch6';
    break;
    default:
    HitSound = Sound'pixie_ouch1';
    break;
  }
  PlaySound(HitSound,SLOT_None,RandRange(0.6,1.0),,10000.0,RandRange(0.80,1.20),,False);
}

function playBiteSound()
{
  local Sound HitSound;
  local int randNum;

  randNum = Rand(5);
  switch (randNum)
  {
    case 0:
    HitSound = Sound'PIX_bite1';
    break;
    case 1:
    HitSound = Sound'PIX_bite2';
    break;
    case 2:
    HitSound = Sound'PIX_bite3';
    break;
    case 3:
    HitSound = Sound'PIX_bite4';
    break;
    case 4:
    HitSound = Sound'PIX_bite5';
    break;
    default:
    HitSound = Sound'PIX_bite1';
    break;
  }
  PlaySound(HitSound,SLOT_None,RandRange(0.6,1.0),,10000.0,RandRange(0.80,1.20),,False);
}

auto state stateIdle
{
begin:
  if ( BOOL_DEBUG_AI )
  {
    PlayerHarry.ClientMessage("" $ string(Name) $ ": auto stateIdle");
  }
  LoopAnim('Fly');
  if ( waitForTrigger == True )
  {
    GotoState('waitingForTrigger');
  } else {
    Sleep(FRand() * 2);
    GotoState('stateLoopSplinePath');
  }
}

state stateLoopSplinePath
{
  function BeginState()
  {
    LoopAnim('Fly');
    StayOnSpline = StayOnSplineDefault;
    // eVulnerableToSpell = 0;
	//eVulnerableToSpell = SPELL_None;
	//DD39: Be castable from the start
	eVulnerableToSpell = SPELL_Rictusempra;
	//DD39: Make checks
	if ( PlayerHarry.bIsCaptured || PlayerHarry.IsInState('CelebrateCardSet') )
	{
	  bHoldOff = True;
	  
	  if ( !bCollOff )
	  {
	    SetCollision(True,False,False);
		bCollOff = True;
	  }
	}
  }
  
  function EndState()
  {
    if ( BOOL_DEBUG_AI )
    {
      PlayerHarry.ClientMessage("" $ string(Name) $ ": EndState : stateLoopSplinePath");
    }
    DestroyControllers();
    AmbientSound = None;
    // SetPhysics(4);
	SetPhysics(PHYS_Flying);
    bCollideWorld = True;
    bAlignBottom = False;
    fxFlyParticleEffect.Shutdown();
	//DD39: Set the flag
	bFXSpawned = False;
  }
  
  function Tick (float DeltaTime)
  {
    Super.Tick(DeltaTime);
	
	//DD39: Make your checks for effects
	if ( !PlayerHarry.bIsCaptured || !PlayerHarry.IsInState('CelebrateCardSet') )
	{
	  if ( !bFXSpawned )
      {
	    bFXSpawned = True;
	    AmbientSound = pixieLoopSound;
	    fxFlyParticleEffect = Spawn(fxFlyParticleEffectClass,,,Location);
	  }
	}
	
	if ( PlayerHarry.bIsCaptured || PlayerHarry.IsInState('CelebrateCardSet') )
	{
	  if ( bFXSpawned )
	  {
	    bFXSpawned = False;
	    AmbientSound = None;
	    fxFlyParticleEffect.Shutdown();
	  }
	}

    StayOnSpline -= DeltaTime;
    if ( StayOnSpline < 0 )
    {
      //DD39: enable collision
	  if ( bCollOff && !PlayerHarry.bIsCaptured && !PlayerHarry.IsInState('CelebrateCardSet') )
	  {
        //DD39: bool is disabled
	    bCollOff = False;
		SetCollision(True,False,True);
	  }
	  // eVulnerableToSpell = 22;
	  //DD39: See BeginState
	  //eVulnerableToSpell = SPELL_Rictusempra;
	  //DD39: They can attack now
	  bHoldOff = False;
      if ( GoAfterHarry() )
      {
        GotoState('stateMoveTowardHarry');
      } else {
        randomTalk -= DeltaTime;
        if ( randomTalk < 0 )
        {
          randomTalk = FRand() * 5 + 1;
          playTalkSound();
        }
      }
    }
	//DD39: Make checks before going into attack state
    if ( VSize(PlayerHarry.Location - Location) < encroachRadius && !bHoldOff && !PlayerHarry.bIsCaptured && !PlayerHarry.bKeepStationary && !PlayerHarry.IsInState('CelebrateCardSet') )
    {
      GotoState('stateAttackHarry');
    }
    fxFlyParticleEffect.SetLocation(Location);
  }
  
 begin:
  if ( BOOL_DEBUG_AI )
  {
    PlayerHarry.ClientMessage("" $ string(Name) $ ": stateLoopSplinePath");
  }
  FollowSplinePath();
}

state stateMoveTowardHarry
{
  //DD39: Added BeginState
  function BeginState()
  {
    bHoldOff = False;
	
	if ( bCollOff && !bDontBlockInAttack )
    {
      bCollOff = False;
	  SetCollision(True,False,True);
    }
	
    if ( !bCollOff && bDontBlockInAttack )
    {
	  SetCollision(True,False,False);
	  bCollOff = True;
    }
  }

begin:
  if ( BOOL_DEBUG_AI )
  {
    PlayerHarry.ClientMessage("" $ string(Name) $ ": state MoveTowardHarry");
  }
  // SetPhysics(4);
  SetPhysics(PHYS_Flying);
  vHome = Location;
  playAttackSound();
  GotoState('stateAttackHarry');
}

state stateAttackHarry
{
  //DD39: Added BeginState
  function BeginState()
  {
	bHoldOff = False;
	
	if ( bCollOff && !bDontBlockInAttack )
    {
      bCollOff = False;
	  SetCollision(True,False,True);
    }
	
	if ( !bCollOff && bDontBlockInAttack )
    {
	  SetCollision(True,False,False);
	  bCollOff = True;
    }
  }
  
  function Tick (float DeltaTime)
  {
    Super.Tick(DeltaTime);
    if ( VSize(Location - PlayerHarry.Location) <= PlayerHarry.CollisionRadius + CollisionRadius + 5 )
    {
      //DD39: Do your checks
	  if ( !bHoldOff && !PlayerHarry.bIsCaptured && !PlayerHarry.bKeepStationary && !PlayerHarry.IsInState('CelebrateCardSet') )
      {
        GotoState('DamageHarry');
      }
    }
	
    if ( VSize(vHome - PlayerHarry.Location) > StopAttackDistance )
    {
      Velocity = vect(0.00,0.00,0.00);
      Acceleration = vect(0.00,0.00,0.00);
      GotoState('HarryGotAway');
    }
  }
  
 begin:
  LoopAnim('Fly');
 loop:
  //DD39: Replaced "+ Vec(0.0,0.0,-25.0)" with "+ Vec(0.0,0.0,5.0)" to help them bite more easily
  vHarryAttackPosition = PlayerHarry.Location + (vector(Rotation) * (PlayerHarry.CollisionRadius + CollisionRadius + 5)) + Vec(0.0,0.0,5.0);
  MoveTo(vHarryAttackPosition);
  Sleep(0.1);
  goto ('Loop');
}

state DamageHarry
{
begin:
  Velocity = vect(0.00,0.00,0.00);
  Acceleration = vect(0.00,0.00,0.00);
  PlayAnim('Attack',3.0);
  Sleep(0.3);
  playBiteSound();
  Sleep(0.1);
  //DD39: Check distance before dealing damage
  if ( VSize(Location - PlayerHarry.Location) <= PlayerHarry.CollisionRadius + CollisionRadius + 5 )
  {
    PlayerHarry.TakeDamage(fDamageAmount,Pawn(Owner),Location,Velocity * 1,'Pixie');
  }
  GotoState('stateRunAway');
}

state stateRunAway
{
  //DD39: Added BeginState
  function BeginState()
  {
	bCollideWorld = False;
    bAlignBottom = True;
    bHoldOff = True;
   
    if ( !bCollOff )
    {
      SetCollision(True,False,False);
	  bCollOff = True;
    }
	AirSpeed = AirSpeed * 1.25;
  }
  
  //DD39: Added EndState
  function EndState()
  {
	AirSpeed = AirSpeed / 1.25;
  }
 
 begin:
  if ( BOOL_DEBUG_AI )
  {
    PlayerHarry.ClientMessage("" $ string(Name) $ ": stateRunAway");
  }
  LoopAnim('Fly');
  // if ( VSize(Location - vHome) > 35 )
  while ( VSize(Location - vHome) > 35 )
  {
    DistanceHome = VSize(Location - vHome);
    MoveTo(vHome);
    Sleep(0.2);
    if ( DistanceHome - VSize(Location - vHome) < 5 )
    {
      if ( vHome != vOriginalHome )
      {
        vHome = vOriginalHome;
      } else {
        MoveTo(PlayerHarry.Location);
        Sleep(0.2);
      }
    }
    // goto JL0037;
  }
  GotoState('stateLoopSplinePath');
}


//DD39: This only handles actual stunning
state stateHitByRictusempra
{
  //DD39: Added BeginState
  function BeginState()
  {
    bHoldOff = True;
	
	if ( bCollOff )
	{
	  bCollOff = False;
	  SetCollision(True,False,True);
	}
  }
  //DD39: Added EndState
  function EndState()
  {
    if ( !bCollOff && ( PlayerHarry.bIsCaptured || PlayerHarry.IsInState('CelebrateCardSet') ) )
	 {
	   SetCollision(True,False,False);
	   bCollOff = True;
	 }
  }
  
begin:

	Velocity = vect(0.00,0.00,0.00);
    Acceleration = vect(0.00,0.00,0.00);
    playHitSound();
    PlayAnim('stun');
    FinishAnim();
    LoopAnim('Idle');
    Sleep(0.1);
	//DD39: Make checks
	if ( bCapturable && ( PlayerHarry.bIsCaptured || PlayerHarry.IsInState('CelebrateCardSet') ) )
	{
	  GotoState('CutIdle');
	} else {
      GotoState('stateRunAway');
	}
}

//DD39: this only handles death
state stateDying
{
  begin:
	SetTimer(timeStunned,False);
    fxFlyParticleEffect.Shutdown();
    SetCollision(False,False,False);
    SetCollisionSize(Default.CollisionRadius / 5, Default.CollisionHeight - Default.CollisionHeight - 1);
    // eVulnerableToSpell = 0;
	eVulnerableToSpell = SPELL_None;
    Velocity = vect(0.00,0.00,0.00);
    Acceleration = vect(0.00,0.00,0.00);
    rHitRotation = Rotation;
    rHitRotation.Pitch = 0;
    DesiredRotation = rHitRotation;
    SetRotation(rHitRotation);
    playHitSound();
    fxHit = Spawn(Class'PixieHit',self,,Location,Rotation);
    LoopAnim('stunspin');
    Sleep(0.15);
    bCollideWorld = True;
    fxHit.Shutdown();
    playAttackSound();
	SetPhysics(PHYS_Walking);
}

state HitGround
{
begin:
  playHitSound();
  GotoState('BlowUpAndDie');
}

state HarryGotAway
{
begin:
  vTemp = Vec(PlayerHarry.Location.X,PlayerHarry.Location.Y,Location.Z);
  vTargetDir = Normal(vTemp - Location);
  DesiredRotation = rotator(vTargetDir);
  LoopAnim('Taunt');
  playAttackSound();
  Sleep(1.5);
  GotoState('stateRunAway');
}

state waitingForTrigger
{
  function Trigger (Actor Other, Pawn EventInstigator)
  {
	waitForTrigger = False;
	bTriggered = True;
	GotoState('Triggered');
  }
  
 begin:
  LoopAnim('Fly');
}

state Triggered
{
  //DD39: Added BeginState
  function BeginState()
  {
	if ( goToPatrolPoint )
	{
	  bCollideWorld = False;
      bAlignBottom = True;
	}
	
	if ( PlayerHarry.bIsCaptured || PlayerHarry.bKeepStationary || PlayerHarry.IsInState('CelebrateCardSet') )
	{
	  bHoldOff = True;
	} else {
	  bHoldOff = False;
	}
	
	if ( bCollOff && !PlayerHarry.bIsCaptured && !PlayerHarry.bKeepStationary && !PlayerHarry.IsInState('CelebrateCardSet') )
	{
	  bCollOff = False;
	  SetCollision(True,False,True);
	}
  }
  //DD39: Added EndState
  function EndState()
  {
    if ( goToPatrolPoint )
	{
	  bCollideWorld = True;
      bAlignBottom = False;
	}
	bTriggered = False;
  }
  //DD39: check for Harry throughout this state
  event Tick (float DeltaTime)
  {
    if ( GoAfterHarry() )
    {
      GotoState('stateMoveTowardHarry');
    }
  }

begin:
  playTalkSound();
  if ( goToPatrolPoint == True )
  {
    foreach AllActors(Class'PatrolPoint',pP,patrolPointTag)
    {
      // goto JL002B;
	  break;
    }
    LoopAnim('Fly');
// JL003C:
    MoveToward(pP);
    // if ( VSize(Location - pP.Location) > 10 )
	while ( VSize(Location - pP.Location) > 10 )
    {
      Sleep(0.05);
      // goto JL003C;
    }
    if ( GoAfterHarry() )
    {
      GotoState('stateMoveTowardHarry');
    } else {
      GotoState('stateLoopSplinePath');
    }
  } else {
    GotoState('stateLoopSplinePath');
  }
}

state BlowUpAndDie
{
begin:
  PlaySound(Sound'horklump_mushroom_head_explode',SLOT_None,RandRange(0.6,1.0),,70000.0,RandRange(0.80,1.20),,False);
  fxBlowUp = Spawn(Class'PixieExplode',self,,Location,Rotation);
  Sleep(0.1);
  if ( fxBlowUp != None )
  {
    fxBlowUp.Shutdown();
  }
  Destroy();
}

defaultproperties
{
    fxFlyParticleEffectClass=Class'HPParticle.PixieFlying'

    pixieLoopSound=Sound'HPSounds.Critters_sfx.PIX_wingflap_loop'

    numAttacksDefault=2

    fDamageAmount=2.00

    timeStunned=2.00

    encroachRadius=50.00

    //DD39: StayOnSplineDefault=3.00
	StayOnSplineDefault=2.25

    StopAttackDistance=800.00

    bThrownObjectDamage=True

    GroundSpeed=75.00

    AirSpeed=120.00

    SightRadius=400.00

    PeripheralVision=1.00

    WalkAnimName=Fly

    RunAnimName=Fly

    // Physics=4
	Physics=PHYS_Flying

    // eVulnerableToSpell=22
	eVulnerableToSpell=SPELL_Rictusempra
	
    Mesh=SkeletalMesh'HPModels.skcornishpixieMesh'

    DrawScale=2.00

    AmbientGlow=200

    SoundRadius=75

    CollisionRadius=30.00

    CollisionHeight=20.00

    bBlockActors=False

    RotationRate=(Pitch=50000,Yaw=50000,Roll=50000)
}
