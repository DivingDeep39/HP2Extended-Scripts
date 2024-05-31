//================================================================================
// firecrabLarge.
//================================================================================

class firecrabLarge extends firecrab;

const BOOL_DEBUG_AI= false;
var spellFireLarge largeSpell;
var spellFireSmall smallSpell;
var int Counter;
var Vector spellLocation;
var Vector TempVector;
var Rotator TempRotator;
var Vector spellOrigin;
var int SpellSpraySpreadAmount;
var() float smallSpellDamage;
var() float largeSpellDamage;
var() float GrenadeRadius;
var() float timeBetweenShots;
var() float fLargeIncreaseHitTimeDistance;
var() float fLargeHitTimeIncrement;
var() float fSmallIncreaseHitTimeDistance;
var() float fSmallHitTimeIncrement;
var() int iAccuracyMin;
var() int iAccuracyMax;
var() bool bPlayRoar;
var() float GrenadeBounceInterval;
var() float GrenadeGravity;
var() float GrenadeOnlyDistance;
var() float GrenadeExplosionGravity;

function bool HandleSpellFlipendo (optional baseSpell spell, optional Vector vHitLocation)
{
  Super.HandleSpellFlipendo(spell,vHitLocation);
  GotoState('stateHitBySpell');
  return True;
}

function bool HandleSpellRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
  local Vector V;

  Super.HandleSpellRictusempra(spell,vHitLocation);
  if (  !IsInState('stayFlipped') )
  {
    if (  --iNumSpellHitsToFlip <= 0 )
    {
      GotoState('stateHitBySpell');
    }
  }
  return True;
}

function Tick (float DeltaTime)
{
  Super.Tick(DeltaTime);
  if (  !IsInState('AttackHarry') &&  !IsInState('throwing') &&  !IsInState('stateHitBySpell') &&  !IsInState('DoFlip') &&  !IsInState('stayFlipped') )
  {
    TimeUntilNextFire -= DeltaTime;
    if ( TimeUntilNextFire < 0 )
    {
      //DD39: Added "&& !PlayerHarry.bIsCaptured && !PlayerHarry.bKeepStationary && !PlayerHarry.IsInState('CelebrateCardSet')"
	  if ( (VSize(PlayerHarry.Location - Location) < fAttackRange) && PlayerCanSeeMe() && !PlayerHarry.bIsCaptured && !PlayerHarry.bKeepStationary && !PlayerHarry.IsInState('CelebrateCardSet') )
      {
        TimeUntilNextFire = TimeUntilNextFireDefault;
        GotoState('AttackHarry');
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
    RoarSound = Sound'firecrab_large_roar';
    break;
    case 1:
    RoarSound = Sound'firecrab_large_roar_A';
    break;
    case 2:
    RoarSound = Sound'firecrab_large_roar_B';
    break;
    case 3:
    RoarSound = Sound'firecrab_large_roar_C';
    break;
    default:
  }
  PlaySound(RoarSound,SLOT_None,RandRange(0.6,1.0),,10000.0,RandRange(0.80,1.20),,False);
}

state stateHitBySpell
{
begin:
  if ( BOOL_DEBUG_AI )
  {
    PlayerHarry.ClientMessage(string(Name) $ " : State stateHitBySpell ");
  }
  PlayerHarry.ClientMessage("Velocity: " $ string(Velocity));
  AmbientSound = None;
  fHighestZ = Location.Z;
  GotoState('DoFlip');
}

state DoFlip
{
begin:
  if ( BOOL_DEBUG_AI )
  {
    PlayerHarry.ClientMessage(string(Name) $ " : State Do Flip ");
  }
  // eVulnerableToSpell = 13;
  eVulnerableToSpell = SPELL_Flipendo;
  RotationRate.Yaw = 50000;
  playHitSound();
  PlayAnim('flip2back');
  Sleep(1.0);
  // if ( bool(Physics) != bool(2) )
  if(Physics != PHYS_Falling)
  {
    PlaySound(Sound'SPI_large_LandOnBack',SLOT_None,RandRange(0.89999998,1.0),,200000.0,RandRange(0.80,1.20),,False);
  }
  Sleep(1.0);
  GotoState('stayFlipped');
}

state AttackHarry
{
	// DD39: Added Tick event to follow Harry.
	event Tick(float DeltaTime)
	{
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
    TurnTo(PlayerHarry.Location);
    PlayRoarSound();
    PlayAnim('roar');
    FinishAnim();
  }
  // DD39: Disable following.
  Disable('tick');
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

state throwing
{
  function BeginState()
  {
    spellLocation = vect(0.00,0.00,0.00);
  }
  
 begin:
  Velocity = vect(0.00,0.00,0.00);
  Acceleration = vect(0.00,0.00,0.00);
  TurnTo(Location + (Location - PlayerHarry.Location));
  if ( VSize(PlayerHarry.Location - Location) < GrenadeOnlyDistance )
  {
    PlaySound(Sound'firecrab_preattack',SLOT_None);
    PlayAnim('preattack');
    FinishAnim();
  }
  
  // DD39: If Harry's not on sight anymore, go back to patrol.
  if ( !LineOfSightTo(PlayerHarry) )
  {
    if ( firstPatrolPointObjectName != '' )
    {
	  SetWalkingSound();
	  GotoState('patrol');
    } else {
      TurnTo(Location + vMoveDir);
      SetWalkingSound();
      GotoState('patrol');
    }
  }
  
  // Counter = 0;
  // if ( Counter < 4 )
  for(Counter = 0; Counter < 4; Counter++)
  {
    if ( VSize(PlayerHarry.Location - Location) < GrenadeOnlyDistance )
    {
      DesiredRotation.Yaw = rotator(Location - PlayerHarry.Location).Yaw;
      spellLocation = PlayerHarry.Location - vect(0.00,0.00,5.00) + VRand() * 10;
      TempVector = spellLocation;
      spellOrigin = Location + (-vector(Rotation) * 3);
      spellOrigin = spellOrigin + Vec(0.0,0.0,13.0);
      smallSpell = Spawn(Class'spellFireSmall',,,spellOrigin,Rotation);
      smallSpell.iDamage = smallSpellDamage;
	  smallSpell.hitTarget = spellLocation;
      smallSpell.fIncreaseHitTimeDistance = fSmallIncreaseHitTimeDistance;
      smallSpell.fHitTimeIncrement = fSmallHitTimeIncrement;
      smallSpell.iAccuracyMin = iAccuracyMin;
      smallSpell.iAccuracyMax = iAccuracyMax;
      PlaySound(AttackSound,SLOT_None);
      PlayAnim('Attack');
      FinishAnim();
    }
    Sleep(timeBetweenShots);
    // Counter++;
    // goto JL0082;
  }
  
  // DD39: If Harry's not on sight anymore, go back to patrol.
  if ( !LineOfSightTo(PlayerHarry) )
  {
    if ( firstPatrolPointObjectName != '' )
    {
	  SetWalkingSound();
	  GotoState('patrol');
    } else {
      TurnTo(Location + vMoveDir);
      SetWalkingSound();
      GotoState('patrol');
    }
  }
  
  PlaySound(Sound'firecrab_preattack',SLOT_None);
  PlayAnim('preattack');
  FinishAnim();
  
  // DD39: If Harry's not on sight anymore, go back to patrol.
  if ( !LineOfSightTo(PlayerHarry) )
  {
    if ( firstPatrolPointObjectName != '' )
    {
	  SetWalkingSound();
	  GotoState('patrol');
    } else {
      TurnTo(Location + vMoveDir);
      SetWalkingSound();
      GotoState('patrol');
    }
  }
  
  //DD39(start): added rotation and location casts
  DesiredRotation.Yaw = rotator(Location - PlayerHarry.Location).Yaw;
  spellLocation = PlayerHarry.Location - vect(0.00,0.00,5.00) + VRand() * 10;
  TempVector = spellLocation;
  spellOrigin = Location + (-vector(Rotation) * 3);
  spellOrigin = spellOrigin + Vec(0.0,0.0,12.0);
  //DD39 (end)
  //DD39: replaced "Location + Vec(0.0,0.0,12.0)" with "spellOrigin" and replaced "Rotation + rot(0,32768,0)" with "Rotation"
  largeSpell = Spawn(Class'spellFireLarge',self,,spellOrigin,Rotation);
  largeSpell.fIncreaseHitTimeDistance = fLargeIncreaseHitTimeDistance;
  largeSpell.fHitTimeIncrement = fLargeHitTimeIncrement;
  largeSpell.iDamage = largeSpellDamage;
  largeSpell.GrenadeRadius = GrenadeRadius;
  largeSpell.smallDamage = smallSpellDamage;
  largeSpell.GrenadeBounceInterval = GrenadeBounceInterval;
  largeSpell.GrenadeGravity = GrenadeGravity;
  largeSpell.GrenadeExplosionGravity = GrenadeExplosionGravity;
  //DD39(start): added missing attack sound and animation
  PlaySound(AttackSound,SLOT_None);
  PlayAnim('Attack');
  FinishAnim();
  //DD39(end)
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

defaultproperties
{
    SpellSpraySpreadAmount=3000

    smallSpellDamage=5.00

    largeSpellDamage=10.00

    GrenadeRadius=200.00

    timeBetweenShots=0.70

    fLargeIncreaseHitTimeDistance=200.00

    fLargeHitTimeIncrement=0.50

    fSmallIncreaseHitTimeDistance=200.00

    fSmallHitTimeIncrement=0.50

    iAccuracyMin=50

    iAccuracyMax=100

    bPlayRoar=True

    GrenadeBounceInterval=2.00

    GrenadeGravity=-512.00

    GrenadeOnlyDistance=500.00

    GrenadeExplosionGravity=-350.00

    WalkingSound=Sound'HPSounds.Critters_sfx.firecrab_walk'

    RoarSound=Sound'HPSounds.Critters_sfx.firecrab_large_roar'

    AttackSound=Sound'HPSounds.Critters_sfx.firecrab_large_attack'

    fAttackRange=1000.00

    iNumSpellHitsToFlipDefault=3

    bFlipPushable=True

    soundFalling(0)=Sound'HPSounds.Critters_sfx.firecrab_large_falling'

    soundFalling(1)=Sound'HPSounds.Critters_sfx.firecrab_large_falling_A'

    lockSpell=True

    SightRadius=1000.00

    PeripheralVision=0.05

    BaseEyeHeight=30.00

    EyeHeight=30.00

    DrawScale=4.00

    MultiSkins(1)=WetTexture'HPParticle.hp_fx.General.Gem2Wet'

    SoundRadius=25

    CollisionRadius=52.00

    CollisionHeight=44.00

    Mass=200.00

}
