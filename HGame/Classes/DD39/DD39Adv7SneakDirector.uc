//================================================================================
// DD39Adv7SneakDirector.
//================================================================================

class DD39Adv7SneakDirector extends Director;

var() Name eCaughtEvent0;
var() Name eCaughtEvent1;
var() Name eCaughtEvent2;
var() Name eCaughtEvent3;
var() Name eCaughtEvent4;
var() Name mChaseMusicEvent;
var() Name mSilenceMusicEvent;
var bool bIsSpotted;
var int iCaughtCounter;
var HChar Characters;

function PreBeginPlay()
{
  Super.PreBeginPlay();
  
  foreach AllActors(Class'HChar',Characters)
  {
    break;
  }
}

function PostBeginPlay()
{
  Super.PostBeginPlay();
}

function HarrySpotted()
{
  if (bIsSpotted)
  {
    return;
  } else {
  bIsSpotted = True;
  TriggerEvent(mSilenceMusicEvent,None,None);
  TriggerEvent(mChaseMusicEvent,None,None);
  }
}

function HarryCaught()
{
  bIsSpotted = False;
	
  if ( iCaughtCounter <= 4 )
   {
     iCaughtCounter++;
   }
}

function TriggerCaughtEvent()
{
  bIsSpotted = False;
	
  if (iCaughtCounter == 1)
  {
	TriggerEvent(eCaughtEvent0,None,None);
  }
	
  if (iCaughtCounter == 2)
  {
	TriggerEvent(eCaughtEvent1,None,None);
  }
	
  if (iCaughtCounter == 3)
  {
	TriggerEvent(eCaughtEvent2,None,None);
  }
	
  if (iCaughtCounter == 4)
  {
	TriggerEvent(eCaughtEvent3,None,None);
  }
	
  if (iCaughtCounter >= 5)
  {
	TriggerEvent(eCaughtEvent4,None,None);
  }
}

function OnTouchEvent (Pawn Subject, Actor Object)
{
  //PlayerHarry.ClientMessage(string(Subject.Name) $ " touched " $ string(Object.Name));
}

function OnUnTouchEvent (Pawn Subject, Actor Object)
{
  //PlayerHarry.ClientMessage(string(Subject.Name) $ " untouched " $ string(Object.Name));
}

function OnBumpEvent (Pawn Subject, Actor Object)
{
  //PlayerHarry.ClientMessage(string(Subject.Name) $ " bumped " $ string(Object.Name));
}

function OnHitEvent (Pawn Subject)
{
  //PlayerHarry.ClientMessage(string(Subject.Name) $ " hit an obstacle");
}

function OnTakeDamage (Pawn Subject, int Damage, Pawn InstigatedBy, name DamageType)
{
  //PlayerHarry.ClientMessage(string(Subject.Name) $ " took '" $ string(DamageType) $ "' damage");
}

function OnCutSceneEvent (name CutSceneTag)
{
  //PlayerHarry.ClientMessage("CutScene " $ string(CutSceneTag) $ " triggered Director");
}

function OnTriggerEvent (Actor Other, Pawn EventInstigator)
{
  //PlayerHarry.ClientMessage(string(Other) $ " triggered Director with " $ string(EventInstigator));
}

function OnPlayerDying()
{
  //PlayerHarry.ClientMessage("Player dying...");
}

function OnPlayersDeath()
{
  //PlayerHarry.ClientMessage("Director: Player died");
}

function OnActionKeyPressed()
{
  //PlayerHarry.ClientMessage("Action key pressed");
}