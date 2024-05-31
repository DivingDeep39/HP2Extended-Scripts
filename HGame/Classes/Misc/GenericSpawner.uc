//================================================================================
// GenericSpawner.
//================================================================================

class GenericSpawner extends HPawn;

const MAX_SPAWNED_GOODIES= 8;
struct MaxMin
{
  var() int Max;
  var() int Min;
};
struct Sounds
{
  var() Sound Opening;
  var() Sound Closing;
  var() Sound Spawning;
};

struct Animations
{
  var() name Opening;
  var() name Closing;
  var() name Start;
  var() name End;
};

var() Class<Actor> GoodieToSpawn[8];
var() int GoodiesNumber[8];
var() name EventName;
var() Animations Anims;
var() Sounds Snds;
var() MaxMin Limits;
var() name StartBone;
var() Vector StartPos;
var() Vector StartVel;
var() Class<ParticleFX> BaseParticles;
var() float BaseDelay;
var() float GoodieDelay;
var() int Lives;
var() bool bDestroable;
var() bool bMakeSpawnPersistent;
var bool bInitialized;
var Vector BaseParticlePos;
var bool bSpawnExactNumbers;
var int HowManyObjectsToSpawn;
var int RandomNums;
var int CurrentNum;
var int CurrentNum1;
var ESpellType eVulnerableToSpellSaved;
//DD39: adding a string to set the global key
var() string GlobalSpawnerKey;
//DD39: bool to prevent items spawning after the spawner has finished
var bool bEnded;
//DD39: bool to prevent the spawning while the spawner is still opening/closing
var bool bSpellHit;

auto state stateStart
{
begin:
  if ( Lives <= 0 )
  {
    if ( Anims.End != 'None' )
    {
      LoopAnim(Anims.End);
    }
  } else //{
    if ( Anims.Start != 'None' )
    {
      LoopAnim(Anims.Start);
    }
  //DD39: added check function for the global key to get
  CheckGlobalSpawnerKey();
  //}
}

state stateEnd
{ 
begin:
  //DD39: the spawner is permanently marked as ended since it ran out of lives
  bEnded=True;
  if ( bDestroable )
  {
    Destroy();
  }
  if ( Anims.End != 'None' )
  {
	LoopAnim(Anims.End);
  }
}

state stateHitBySpell
{
begin:
  //DD39: the spawner won't accept new spells in this state
  bSpellHit=True;
  // eVulnerableToSpell = 0;
  eVulnerableToSpell = SPELL_None;
  if ( Lives > 0 )
  {
    Lives--;
  }
  FinishAnim();
  if ( Anims.Opening != 'None' )
  {
    if ( Snds.Opening != None )
    {
      PlaySound(Snds.Opening,SLOT_None);
    }
    PlayAnim(Anims.Opening);
    Sleep(BaseDelay);
    FinishAnim();
  }
  if ( BaseParticles != None )
  {
    FindBaseParticlePos();
    Spawn(BaseParticles,,,[SpawnLocation]BaseParticlePos);
  }
  if ( Limits.Min >= Limits.Max )
  {
    RandomNums = Limits.Min;
  } else {
    RandomNums = RandRange(Limits.Min,Limits.Max);
	}
	if (  !bSpawnExactNumbers )
    {
      // CurrentNum = 0;
      // if ( CurrentNum < RandomNums )
	  for(CurrentNum = 0; CurrentNum < RandomNums; CurrentNum++)
      {
        Sleep(GoodieDelay);
        SpawnObject(-1);
        // CurrentNum++;
      }
    } else {
      // CurrentNum = 0;
      // if ( CurrentNum < 8 )
	  for(CurrentNum = 0; CurrentNum < MAX_SPAWNED_GOODIES; CurrentNum++)
      {
        // CurrentNum1 = 0;
        // if ( CurrentNum1 < GoodiesNumber[CurrentNum] )
		for(CurrentNum1 = 0; CurrentNum1 < GoodiesNumber[CurrentNum]; CurrentNum1++)
        {
          Sleep(GoodieDelay);
          SpawnObject(CurrentNum);
          // CurrentNum1++;
        }
        // CurrentNum++;
      }
    }
  if ( Snds.Spawning != None )
  {
    PlaySound(Snds.Spawning,SLOT_Misc);
  }
  if ( Lives > 0 )
  {
    if ( Anims.Closing != 'None' )
    {
      if ( Snds.Closing != None )
      {
        PlaySound(Snds.Closing,SLOT_None);
      }
      PlayAnim(Anims.Closing);
      FinishAnim();
	  //DD39: the spawner can receive new spells now
	  bSpellHit=False;
    }
    eVulnerableToSpell = eVulnerableToSpellSaved;
    GotoState('stateStart');
  } else {
    // eVulnerableToSpell = 0;
	eVulnerableToSpell = SPELL_None;
    if ( EventName != 'None' )
    {
      TriggerEvent(EventName,None,None);
    }
	//DD39: added function to set the global key
	SetGlobalSpawnerKey();
    GotoState('stateEnd');
  }
}

function PostBeginPlay()
{
  local int I;

  Super.PostBeginPlay();
  if (  !bInitialized )
  {
    eVulnerableToSpellSaved = eVulnerableToSpell;
    bInitialized = True;
  }
  HowManyObjectsToSpawn = 0;

  for(I = 0; I < MAX_SPAWNED_GOODIES; I++)
  {
    if ( GoodieToSpawn[I] == None )
    {
	  break;
    }
  }
  HowManyObjectsToSpawn = I;
  if ( Lives <= 0 )
  {
    HowManyObjectsToSpawn = 0;
  }
  bSpawnExactNumbers = False;

  for(I = 0; I < MAX_SPAWNED_GOODIES; I++)
  {
    if ( GoodiesNumber[I] != 0 )
    {
      bSpawnExactNumbers = True;
    }
  }
  if ( HowManyObjectsToSpawn <= 0 )
  {
	eVulnerableToSpell = SPELL_None;
  }
}

//DD39: added function to set the global key
function SetGlobalSpawnerKey()
{
	if (GlobalSpawnerKey != "")
		{
			SetGlobalBool(GlobalSpawnerKey,true);
		}
}

//DD39: added function to get the global key
function CheckGlobalSpawnerKey()
{
	if (GetGlobalBool(GlobalSpawnerKey))
	{
		GotoState('stateEnd');
		eVulnerableToSpell=SPELL_None;
		/*if ( bDestroable )
		{
			Destroy();
		}
		if ( Anims.End != 'None' )
		{
			//GotoState('stateEnd');
			LoopAnim(Anims.End);
			eVulnerableToSpell=SPELL_None;
		}*/
	}
}

function FindBaseParticlePos()
{
  local Vector Dir;
  local int bNum;

  Dir = StartPos;
  Dir = Dir >> Rotation;
  if ( StartBone != 'None' )
  {
    bNum = BoneNumber(StartBone);
    if ( bNum >= 0 )
    {
      Dir = BonePos(StartBone);
      Dir = Dir - Location;
    }
  }
  BaseParticlePos = Dir + Location;
}

function SpawnObject (int Index)
{
  local Vector Dir;
  local Vector Vel;
  local Actor newSpawn;
  local int bNum;
  local Vector V;
  local Vector N;
  local float Length;
  local float angle;

  if ( HowManyObjectsToSpawn <= 0 )
  {
    return;
  }
  N = vector(Rotation);
  N.Z = 0.0;
  // if ( True )
  while(True)
  {
    angle = RandRange(0.0,6.28319979);
    V.X = Cos(angle);
    V.Y = Sin(angle);
    V.Z = 0.0;
    if ( (N.X == 0.0) && (N.Y == 0.0) )
    {
      // goto JL00CA;
	  break;
    }
    if ( (V Dot N) / VSize2D(N) > 0.69999999 )
    {
      // goto JL00CA;
	  break;
    }
    // goto JL0029;
  }
  Length = RandRange(50.0,100.0);
  Vel.X = Length * Cos(angle);
  Vel.Y = Length * Sin(angle);
  Vel.Z = 100.0 + FRand() * 100;
  Dir = StartPos;
  Dir = Dir >> Rotation;
  if ( StartBone != 'None' )
  {
    bNum = BoneNumber(StartBone);
    if ( bNum >= 0 )
    {
      Dir = BonePos(StartBone);
      Dir = Dir - Location;
    }
  }
  Dir = Dir + Location;
  if ( Index < 0 )
  {
    newSpawn = Spawn(GoodieToSpawn[Rand(HowManyObjectsToSpawn)],,,[SpawnLocation]Dir);
  } else {
    newSpawn = Spawn(GoodieToSpawn[Index],,,[SpawnLocation]Dir);
  }
  if ( (StartVel.X == 0) && (StartVel.Y == 0) && (StartVel.Z == 0) )
  {
    newSpawn.Velocity = Vel;
  } else {
    newSpawn.Velocity = StartVel;
  }
  newSpawn.SetPhysics(PHYS_Falling);
  switch (Rand(3))
  {
    case 0:
    Spawn(Class'Spawn_flash_1',,,[SpawnLocation]Dir);
    break;
    case 1:
    Spawn(Class'Spawn_flash_2',,,[SpawnLocation]Dir);
    break;
    case 2:
    Spawn(Class'Spawn_flash_3',,,[SpawnLocation]Dir);
    break;
    default:
  }
  switch (Rand(3))
  {
    case 0:
    PlaySound(Sound'spawn_bean01');
    break;
    case 1:
    PlaySound(Sound'spawn_bean02');
    break;
    case 2:
    PlaySound(Sound'spawn_bean03');
    break;
    default:
  }
  newSpawn.bPersistent = bMakeSpawnPersistent;
}

function bool HandleSpellFlipendo (optional baseSpell spell, optional Vector vHitLocation)
//DD39: first the spawner checks if the spell is the correct one (eVulnerableToSpell)
//then checks if it hasn't run out of lives (!bEnded)
//and also if it's not currently handling a spell (!bSpellHit)
{
  if ( eVulnerableToSpell == SPELL_Flipendo )
  {
	if (!bEnded && !bSpellHit)
	{  
		Super.HandleSpellFlipendo(spell,vHitLocation);
		GotoState('stateHitBySpell');
		return True;
	}
  }
}

function bool HandleSpellAlohomora (optional baseSpell spell, optional Vector vHitLocation)
{
  if ( eVulnerableToSpell == SPELL_Alohomora )
  {
	if (!bEnded && !bSpellHit)
	{ 
		Super.HandleSpellAlohomora(spell,vHitLocation);
		GotoState('stateHitBySpell');
		return True;
	}
  }
}

function bool HandleSpellDiffindo (optional baseSpell spell, optional Vector vHitLocation)
{
  if ( eVulnerableToSpell == SPELL_Diffindo )
  {
	if (!bEnded && !bSpellHit)
	{ 
		Super.HandleSpellDiffindo(spell,vHitLocation);
		GotoState('stateHitBySpell');
		return True;
	}
  }
}

function bool HandleSpellEcto (optional baseSpell spell, optional Vector vHitLocation)
{
  if ( eVulnerableToSpell == SPELL_Ecto )
  {
	if (!bEnded && !bSpellHit)
	{ 
		Super.HandleSpellEcto(spell,vHitLocation);
		GotoState('stateHitBySpell');
		return True;
	}
  }
}

function bool HandleSpellLumos (optional baseSpell spell, optional Vector vHitLocation)
{
  if ( eVulnerableToSpell == SPELL_Lumos )
  {
	if (!bEnded && !bSpellHit)
	{  
		Super.HandleSpellLumos(spell,vHitLocation);
		GotoState('stateHitBySpell');
		return True;
	}
  }
}

function bool HandleSpellRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
  if ( eVulnerableToSpell == SPELL_Rictusempra )
  {
	if (!bEnded && !bSpellHit)
	{  
		Super.HandleSpellRictusempra(spell,vHitLocation);
		GotoState('stateHitBySpell');
		return True;
	}
  }
}

function bool HandleSpellSkurge (optional baseSpell spell, optional Vector vHitLocation)
{
  if ( eVulnerableToSpell == SPELL_Skurge )
  {
	if (!bEnded && !bSpellHit)
	{   
		Super.HandleSpellSkurge(spell,vHitLocation);
		GotoState('stateHitBySpell');
		return True;
	}
  }
}

function bool HandleSpellSpongify (optional baseSpell spell, optional Vector vHitLocation)
{
  if ( eVulnerableToSpell == SPELL_Spongify )
  {
	if (!bEnded && !bSpellHit)
	{   
		Super.HandleSpellSpongify(spell,vHitLocation);
		GotoState('stateHitBySpell');
		return True;
	}
  }
}

defaultproperties
{
    Anims=(Opening=Open,Closing=Close,Start=Start,End=End)

    Limits=(Max=6,Min=2)

    StartPos=(X=0.00,Y=0.00,Z=40.00)

    Lives=1

    bMakeSpawnPersistent=True

    // Physics=2
	Physics=PHYS_Falling

    // eVulnerableToSpell=13
	eVulnerableToSpell=SPELL_Flipendo

    bPersistent=True

    Mesh=SkeletalMesh'HPModels.skcigarboxMesh'

    // CollideType=3
	CollideType=CT_Shape
}
