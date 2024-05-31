//================================================================================
// DD39SleepingGoyle.
//================================================================================

class DD39SleepingGoyle extends SleepingGoyle;

var string SnoringSoundName; 
var Sound SnoringSound;
var() Name EventBusted;
var() Name EventWarnHarry;
var DD39Pig myPigs[4];
var int numPigs;

function PostBeginPlay()
{
    local DD39Pig tempPigs;
	
	Super.PostBeginPlay();
	
	SnoringSoundName = "PC_GOY_Adv6Goyle_11";
    SnoringSound = Sound(DynamicLoadObject("AllDialog." $SnoringSoundName,Class'Sound'));
	
	//DD39: Add myPigs
	foreach AllActors(Class'DD39Pig', tempPigs)
	{
		myPigs[numPigs] = tempPigs;
		numPigs++;
	}
}

function PlayGoyleSnoring()
{
    //DD39: Added Radius 768.0
	PlaySound(SnoringSound, SLOT_Misc, , true, 768.0);    
}

function StopGoyleSnoring()
{
    StopSound(SnoringSound, SLOT_Misc);
}

function PigWakeGoyle()
{
  if ( !IsInState('stateSleep') )
  {
    return;
  }
  if ( PlayerHarry.IsInState('statePickBitOfGoyle') || PlayerHarry.bIsCaptured )
  {
    return;
  }
  WakeLevel++;
  GotoState('stateWakeUp');
}

function bool CutCommand (string Command, optional string cue, optional bool bFastFlag)
{
  local string sActualCommand;

  sActualCommand = ParseDelimitedString(Command," ",1,False);
  
  if ( sActualCommand ~= "ResetPigs" )
  {
	return CutCommand_ResetPigs(Command,cue,bFastFlag);
  }
  else if ( sActualCommand ~= "Release" )
  {
	GotoState('stateSleep');
    return True;
  }
  return Super.CutCommand(Command,cue,bFastFlag);
}

function bool CutCommand_ResetPigs (string Command, optional string cue, optional bool bFastFlag)
{
	local int i;
	
	if ( numPigs != 0 )
	{
		for(i = 0; i < numPigs; i++)
		{
			if ( myPigs[i] != None )
			{
				myPigs[i].StopSound();
				//myPigs[i].bActive = False;
				//myPigs[i].eVulnerableToSpell = SPELL_None;
				myPigs[i].GotoState('patrol');
			}
		}
	}

	WakeLevel = 0;
	
	if(bFastFlag)
	{
		CutNotifyActor.CutCue(cue);
		return true;
	}
	
	CutCue(cue);
	return true;
}
	
auto state stateSleep 
{
  function Bump (Actor Other)
  {
    if ( Other == PlayerHarry )
    {
      harry(Other).GotoState('statePickBitOfGoyle');
    }
  }
  
  function EndState()
  {
    StopGoyleSnoring();
  }
  
 begin:
  PlayAnim('Goyle_sleeping');
  FinishAnim();
  PlayGoyleSnoring();
  Sleep(0.01);
  goto ('Begin');
}

state stateWakeUp
{
begin:
  if ( WakeLevel == 1 )
  {
    PlayAnim('Goyle_Groggy');
    FinishAnim();
  } else //{
    if ( WakeLevel == 2 )
    {
      PlayAnim('Goyle_Groggy');
      FinishAnim();
    } else //{
      if ( WakeLevel == 3 )
      {
        PlayAnim('Goyle_Groggy');
        FinishAnim();
      } else //{
      if ( WakeLevel == 4 )
      {
		  TriggerEvent(EventBusted,None,None);
          PlayAnim('Goyle_WakeUp');
          FinishAnim();
          GotoState('stateBustHarry');
       }
      //}
    //}
  //}
  if (  !TooCloseToHarry() )
  {
    GotoState('stateSleep');
  } else {
    TriggerEvent(EventWarnHarry,None,None);
	WakeLevel++;
    GotoState('stateWakeUp');
  }
}

state stateBustHarry
{
begin:
  PlayAnim('Goyle_SitUp_Idle');
  FinishAnim();
}
