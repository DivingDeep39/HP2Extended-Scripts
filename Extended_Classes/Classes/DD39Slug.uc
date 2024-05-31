//================================================================================
// DD39Slug.
//================================================================================

class DD39Slug extends orangesnail;

var string LandingSoundName;
var string SquishingSoundName;
var Sound LandingSound;
var Sound SquishingSound;
var float SoundDur;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    LandingSoundName = "SlugLanding";
    LandingSound = Sound(DynamicLoadObject("Extended_Sounds." $LandingSoundName,Class'Sound'));
	SquishingSoundName = "SlugSquishing";
	SquishingSound = Sound(DynamicLoadObject("Extended_Sounds." $SquishingSoundName,Class'Sound'));
}

function HarrySteppedOnTrail (Vector vTrailLocation)
{

}

function DoSnailDamage (name nameDamage, Vector vDamageLoc, bool bCuttingHarryOff)
{

}

event Tick (float DeltaTime)
{
  SoundDur -= DeltaTime;
}

event Touch (Actor Other)
{
    if ( Other.IsA('harry') )
    {
      if ( VSize(PlayerHarry.Velocity) < 5 )
      {
        Velocity = vect(0.00,0.00,0.00);
        Acceleration = vect(0.00,0.00,0.00);
      } else {
		PlaySquishingSound();
	  }
	}
}

event Bump (Actor Other)
{

}

function PlayLandingSound()
{
	if(SoundDur <= 0)
    {
		PlaySound(LandingSound,SLOT_None,RandRange(0.6,1.0),,10000.0,RandRange(0.80,1.20),,False);
		// PlaySound(LandingSound,SLOT_None,,,,,False);
		SoundDur = GetSoundDuration(Sound'SlugLanding');
	}
}

function PlaySquishingSound()
{
	if(SoundDur <= 0)
    {
		PlaySound(SquishingSound,SLOT_None,RandRange(0.6,1.0),,10000.0,RandRange(0.80,1.20),,False);
		// PlaySound(LandingSound,SLOT_None,,,,,False);
		SoundDur = GetSoundDuration(Sound'SlugSquishing');
	}
}

event Landed (Vector HitNormal)
{
  Super.Landed(HitNormal);
  PlayLandingSound();
  // PlaySound(LandingSound,SLOT_None,,,,,False);
  if ( IsInState('patrol') || IsInState('RamHarry') )
  {
    StartTrail();
  }
}

auto state patrol
{
  // ignores  Tick; //UTPT added this for some reason -AdamJD
  
  //UTPT didn't add this for some reason -AdamJD
  event Tick(float fDeltaTime)
  {
	  Global.Tick(fDeltaTime);

	  fPatrolTime += fDeltaTime;

	  if ( bAllowRam && !bCutInProgress && CanSee(playerHarry) && (fPatrolTime >= PATROL_BEFORE_RAM_TIME) )
	  {
		  GoToState('RamHarry');
	  }
  }
  
  function Timer()
  {
    SetTimer(RandRange(3.0,8.0),False);
    if ( Rand(2) == 0 )
    {
    
    }
  }
  
  event BeginState()
  {
    Super.BeginState();
    SetGroundSpeed();
    StartTrail();
    fPatrolTime = 0.0;
    SetTimer(RandRange(3.0,8.0),False);
  }
  
  event EndState()
  {
    SetTimer(0.0,False);
  }
}

defaultproperties
{
    bAllowSnailDamage=False

    fGroundspeedNormal=5.00

    fGroundspeedEcto=0.00

    fGroundspeedRam=0.00

    fGroundspeedEctoRam=0.00

    bAllowRam=False

    nBumpRetreatMin=0.00

    nBumpRetreatMax=0.00

    fTrailDuration=0.00

    fTrailShrinkAfter=0.00

    nMaxTrailSegments=0.00

    fTrailDamageWait=0.00

    nTrailDamage=0.00

    nNormalBodyDamage=0.00

    nRamBodyDamage=0.00

    fStunDuration=0.00

    bFlipPushable=False

    fFlipPushForceZ=0.00

    bThrownObjectDamage=False

    GroundSpeed=5.00

    // eVulnerableToSpell=22
	eVulnerableToSpell=SPELL_None

    Mesh=SkeletalMesh'Extended_Meshes.skSlug'

    DrawScale=0.5

    CollisionRadius=7.050569
	
	CollisionWidth=7.050569

    CollisionHeight=5.00

    bBlockActors=False
	
	bBlockPlayers=False
	
	LODBias=666
	
	GroundWalkSpeed=5.00
	
	GroundWalkSpeed=5.00
	
	SoundVolume=128
	
	ShadowClass=None
}
