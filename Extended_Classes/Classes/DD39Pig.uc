//================================================================================
// DD39Pig.
//================================================================================

class DD39Pig extends HChar;

#define RAND_SNORT_TIME RandRange(MinTimeBtwSnort, MaxTimeBtwSnort)

var(DD39PigSounds) float SnortVolume;
var(DD39PigSounds) float SquealVolume;
var(DD39PigSounds) float MinSquealPitch;
var(DD39PigSounds) float MaxSquealPitch;
var(DD39PigSounds) Array<Sound> SnortSounds;
var(DD39PigSounds) Array<Sound> SquealSounds;

var() bool bInitiallyActive;
var() float MaxTimeBtwSnort;
var() float MinTimeBtwSnort;
var() float TimeStunned;

var bool bActive;
var SleepingGoyle Goyle;

event PreBeginPlay()
{
    Super.PreBeginPlay();

    bActive = bInitiallyActive;
	
	if (bActive)
	{
		eVulnerableToSpell=SPELL_Rictusempra;
	}
	else
	{
		eVulnerableToSpell=SPELL_None;
	}
}

function PostBeginPlay()
{
  Super.PostBeginPlay();
  
  forEach AllActors(Class'SleepingGoyle', Goyle)
    {
        break;
    }

  SetTimer(RAND_SNORT_TIME, false);
}

function Trigger(Actor Other, Pawn EventInstigator)
{
    bActive = !bActive;
	
	if (bActive)
	{
		eVulnerableToSpell=SPELL_Rictusempra;
	}
	else
	{
		eVulnerableToSpell=SPELL_None;
	}
}

function PlaySoundSqueal()
{
    local int decision;
    decision = Rand(SquealSounds.Length);

    PlaySound(SquealSounds[decision], SLOT_Misc, SquealVolume, false, 4096.0, RandRange(MinSquealPitch, MaxSquealPitch), false, false);
}

function PlaySoundSnort()
{
    local int decision;
    decision = Rand(SnortSounds.Length);

    //DD39: Replaced Radius 4096.0 with 1280.0
	PlaySound(SnortSounds[decision], SLOT_Misc, SnortVolume, true, 1280.0, 1.0, false, false);
}

function Timer()
  {
    PlaySoundSnort();
	SetTimer(RAND_SNORT_TIME, false);
  }

function bool HandleSpellRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
  GotoState('stateStun');
  return True;
}

function bool PigCanSee(Actor Seen)
{
    local Vector seen_midpoint;
    local Vector midpoint;

    seen_midpoint = Seen.Location;
    seen_midpoint.z += Seen.CollisionHeight * 0.5;

    midpoint = Location;
    midpoint.z += CollisionHeight * 0.5;

    if (VSize(Seen.Location - Location) > SightRadius)
    {
        return false;
    }
	
    return true;
}

function Tick (float DeltaTime)
{
	Super.Tick(DeltaTime);
	if ( !IsInState('stateSqueal') && !IsInState('stateStun') )
	{
		if (PigCanSee(PlayerHarry) && bActive)
			{
				GoToState('stateSqueal');
			}
	}
}

function HarryIsStillNear()
{
	//if ( VSize(Location - PlayerHarry.Location) < SightRadius )
	if (PigCanSee(PlayerHarry))
		{
			GoToState('stateSqueal');
		}
		else
		{
			GoToState('patrol');
		}
}

state stateStun
{
begin:
  Acceleration = vect(0.00,0.00,0.00);
  Velocity = vect(0.00,0.00,0.00);
  //PlaySoundSqueal();
  eVulnerableToSpell=SPELL_None;
  //DoTurnTo(PlayerHarry, false, true, true);
  PlayAnim('React', 1.3);
  FinishAnim();
  Sleep(TimeStunned);
  PlayAnim('fidget_1');
  FinishAnim();
  //Goyle.PigWakeGoyle();
  eVulnerableToSpell=SPELL_Rictusempra;
  GotoState('patrol');
}

state stateSqueal
{
    event EndState()
    {
        DestroyTurnToPermanentController();
    }
	
begin:
  Acceleration = vect(0.00,0.00,0.00);
  Velocity = vect(0.00,0.00,0.00);
  //TurnTo(PlayerHarry.Location);
  DoTurnTo(PlayerHarry, false, true, true);
  //DesiredRotation.Yaw = Rotation.Yaw;
  PlaySoundSqueal();
  Goyle.PigWakeGoyle();
  PlayAnim('Squeal', 0.7);
  FinishAnim();
  
  HarryIsStillNear();
  GotoState('patrol');
}
	

defaultproperties
{
    AmbientGlow=16
    bInitiallyActive=True
    CollisionHeight=25
    CollisionRadius=40
    eVulnerableToSpell=SPELL_Rictusempra
    GroundSpeed=125.00
    MaxSquealPitch=1.12
    MaxTimeBtwSnort=12.0
    Mesh=SkeletalMesh'HPModels.skPigMesh'
    MinSquealPitch=0.82
    MinTimeBtwSnort=2.0
    RotationRate=(Pitch=0,Yaw=32000,Roll=0)
    SnortSounds(0)=Sound'Pig_snort01'
    SnortSounds(1)=Sound'Pig_snort02'
    SnortSounds(2)=Sound'Pig_snort03'
    SnortSounds(3)=Sound'Pig_snort04'
    SnortSounds(4)=Sound'Pig_snort05'
    SnortSounds(5)=Sound'Pig_snort06'
    SnortSounds(6)=Sound'Pig_snort07'
    SnortSounds(7)=Sound'Pig_snort08'
    SnortSounds(8)=Sound'Pig_snort09'
    SnortSounds(9)=Sound'Pig_snort10'
    SnortVolume=0.9
    SquealSounds(0)=Sound'pig_squeal1'
    SquealVolume=0.9
    TimeStunned=3.23
}