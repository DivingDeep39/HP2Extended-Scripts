//================================================================================
// TriggerChangeLevel.
//================================================================================

class TriggerChangeLevel extends Trigger;

var() string NewMapName;
// DD39: Added PlayerHarry var:
var harry PlayerHarry;

// DD39: Added PreBeginPlay for new player reference:
event PreBeginPlay()
{
  Super.PreBeginPlay();
  
  PlayerHarry = harry(Level.PlayerHarryActor);
}

auto state Waiting
{
  event Trigger (Actor Other, Pawn EventInstigator)
  {
    ProcessTrigger();
	// DD39: Change for new player reference:
    //Level.PlayerHarryActor.ClientMessage(string(self) $ " Here1");
	PlayerHarry.ClientMessage(string(self) $ " Here1");
  }
  
  function Touch (Actor Other)
  {
    Super.Touch(Other);
	// DD39: Change for new player reference:
    //if ( Other == Level.PlayerHarryActor )
	if ( Other == PlayerHarry )
    {
      ProcessTrigger();
    }
  }
  
}

function ProcessTrigger()
{
  // DD39 (start): Clear:
  //local harry PlayerHarry;

  /*PlayerHarry = harry(Level.PlayerHarryActor);
  if ( PlayerHarry == None )
  {
    Log("TriggerChangeLevel: Couldn't find Harry, and that ain't right!");
    return;
  }*/
  // DD39 (end)
  
  // DD39: if Harry is dead, don't change level:
  if ( PlayerHarry.bInstantDeath || PlayerHarry.bHarryKilled || PlayerHarry.IsInState('stateDead') )
  {
    return;
  }

  PlayerHarry.LoadLevel(NewMapName);
  if ( InStr(Caps(NewMapName),"STARTUP") > -1 )
  {
    HPConsole(PlayerHarry.Player.Console).menuBook.bGamePlaying = False;
    HPConsole(PlayerHarry.Player.Console).menuBook.OpenBook("Main");
    HPConsole(PlayerHarry.Player.Console).LaunchUWindow();
  }
}

defaultproperties
{
    InitialState=None

}
