//================================================================================
// cHarryAnimChannel.
//================================================================================

class cHarryAnimChannel extends AnimChannel;

var HProp propTemp;
var int LastAnimFrame;

// DD39: MaxG: Tweening variables.
var float TempFrame;

// DD39: MaxG: Bool to update frame.
var bool bUpdateFrame;

// DD39: MaxG: For tweening to cast.
var float LastCastTime;

function GotoStateThrow()
{
  GotoState('stateThrow');
}

function bool GotoStateCasting (bool in_bHarryUsingSword)
{
  GotoState('stateCasting');
}

function bool IsCarryingActor()
{
  if ( IsInState('statePickupItem') || IsInState('stateThrow') )
  {
    return True;
  } else {
    return False;
  }
}

function bool CanPickSomethingUp()
{
  return True;
}

function bool PlayHarryMovementAnims()
{
  return True;
}

function Cast()
{
  harry(Owner).Cast();
}

auto state stateIdle
{
  function BeginState()
  {
    harry(Owner).PlayIdle();
  }
}

state statePickupItem
{
  function bool CanPickSomethingUp()
  {
    return False;
  }
  
  function BeginState()
  {
    PlayAnim('Pickup',1.0,0.15);
  }
  
 begin:
  harry(Owner).ClientMessage("hold up arm");
  Sleep(0.2);
  harry(Owner).AttachCarryActor();
  FinishAnim();
  LoopAnim('throwhold',1.0,0.1);
}

state stateThrow
{
  function bool CanPickSomethingUp()
  {
    return False;
  }
  
 begin:
  PlayAnim('throw',1.5);
  Sleep(0.3375 / 1.5);
  harry(Owner).ThrowCarryingActor();
  FinishAnim();
  harry(Owner).HarryAnimType =  AT_Replace;
  GotoState('stateIdle');
}

state stateCasting
{
begin:
  harry(Owner).HarryAnimType =  AT_Combine;
  if ( harry(Owner).bHarryUsingSword )
  {
    LoopAnim('swordaim',1.0,0.2);
  } else //{
    if ( harry(Owner).bInDuelingMode )
    {
      LoopAnim('duel_charge',1.0,0.2);
    } else {
	  // DD39: Cleared out:
      //LoopAnim('CastAim',1.0,0.2);
	  
	  // DD39: MaxG: This check makes it intentionally not tween if Harry is falling and he casted recently.
	  //		 It just makes him snap less and looks less janky, strangely enough.
	  if (Owner.Physics != PHYS_Falling || Harry(Owner).AnimFalling == Harry(Owner).SpongifyFallAnim || (Level.TimeSeconds - LastCastTime) > 0.25)
	  {
		  //AnimFrame = 0.0;
		  PlayAnim(Owner.AnimSequence, 1.0, 0.0);
		  AnimFrame = Owner.AnimFrame;
		  TweenAlpha = Owner.TweenAlpha;
		  Sleep(0.016);
	  }

	  // DD39: MaxG: Only tween the falling animation IF the last cast was recent.
	  //		 If the player is spamming cast, don't tween. It will look weird.
	  if (Owner.Physics == PHYS_Falling)
	  {
	  	  LastCastTime = Level.TimeSeconds;
	  }

	  LoopAnim('CastAim', 1.0, 0.2);
    }
  //}
}

// DD39: MaxG: A hacky fix for the anim sliding while rapidly casting thing.
state DoneAiming
{
	function BeginState()
	{
		Super.BeginState();

		HandleAnimBlending(AT_Replace);
	}
}

// DD39: MaxG: Update the animation frame.
function UpdateFrame()
{
	if (bUpdateFrame)
	{
		Owner.AnimFrame = TempFrame;
		bUpdateFrame = false;
	}
}

// DD39: MaxG: HandleAnimBlending
function HandleAnimBlending(eAnimType AnimType)
{
	// DD39: MaxG: Update the TempFrame
	TempFrame = Owner.AnimFrame;

	// DD39: MaxG: Make Harry animate so that he tweens.
	if (!Harry(Owner).bIsCaptured)
	{
		Owner.PlayAnim(Owner.AnimSequence, , 0.5);
	}

	// DD39: MaxG: Update anim type.
	Harry(Owner).HarryAnimType = AnimType;

	// DD39: MaxG: Update anim frame. This needs to be done again in UpdateFrame(). IDK why.
	Owner.AnimFrame = TempFrame;

	bUpdateFrame = true;
}

state stateCancelCasting
{
begin:
  harry(Owner).ClientMessage("HarryAnimChannel: CancelCasting");
  harry(Owner).CurrIdleAnimName = harry(Owner).GetCurrIdleAnimName();
  PlayAnim(harry(Owner).CurrIdleAnimName,,0.25);
  FinishAnim();
  harry(Owner).StopAiming();
}

state stateDuelingCast
{
begin:
  harry(Owner).Cast();
  harry(Owner).HarryAnimType =  AT_Combine;
  PlayAnim('duel_cast',,[TweenTime]0.3);
  FinishAnim();
  if ( harry(Owner).bAltFire == 0 )
  {
    harry(Owner).StopAiming();
  } else {
    harry(Owner).TurnOffCastingVars();
    harry(Owner).TurnOffSpellCursor();
    harry(Owner).StartAiming(False);
  }
}

state stateDefenceCast
{
  //DD39: function to disable spell rebound after the state code
  //	  and make sure the Expelliarmus Charge Light wears off.
  function EndState()
  {
    harry(Owner).bReboundingSpells = False;
	baseWand(harry(Owner).Weapon).WearOffChargeLight();
  }

begin:
  if ( harry(Owner).fTimeAfterHit > 0 )
  {
    harry(Owner).bReboundingSpells = False;
  } else {
    harry(Owner).bReboundingSpells = True;
  }
  harry(Owner).Cast();
  harry(Owner).HarryAnimType =  AT_Combine;
  PlayAnim('cast_Expelliarmus',,[TweenTime]0.3);
  FinishAnim();
  harry(Owner).bReboundingSpells = False;
  if ( harry(Owner).bAltFire == 0 )
  {
    harry(Owner).StopAiming();
  } else {
    harry(Owner).TurnOffCastingVars();
    harry(Owner).TurnOffSpellCursor();
    harry(Owner).StartAiming(False);
  }
}

state stateCast
{
  function BeginState()
  {
    if ( harry(Owner).bHarryUsingSword )
    {
      PlayAnim('SwordCast',1.5,0.1);
    } else {
      PlayAnim('Cast',2.0,0.1);
    }
  }
  
 begin:
  FinishAnim();
  harry(Owner).StopAiming();
}

function DoKnockBack()
{
  if (  !IsInState('stateKnockBack') &&  !IsInState('stateEctoJump') )
  {
    GotoState('stateKnockBack');
  }
}

state stateKnockBack
{
  function bool CanPickSomethingUp()
  {
    return False;
  }
  
  function BeginState()
  {
    harry(Owner).HarryAnimType =  AT_Combine;
  }
  
 begin:
  if ( harry(Owner).bHarryUsingSword && (baseWand(harry(Owner).Weapon).ChargingLevel() > 0) )
  {
    // DD39: Don't cast, so you can't cheese through the Basilisk fight.
	//baseWand(harry(Owner).Weapon).CastSpell(harry(Owner).Weapon,,Class'spellSwordFire');
    harry(Owner).StopAiming();
  }
  PlayAnim('KnockBack',,0.3);
  FinishAnim();
  harry(Owner).HarryAnimType =  AT_Replace;
  if ( harry(Owner).PlayerIsAiming() )
  {
    GotoState('stateCasting');
  } else {
    GotoState('stateIdle');
  }
}

function DoEctoJump()
{
  if (  !IsInState('stateEctoJump') )
  {
    GotoState('stateEctoJump');
  }
}

state stateEctoJump
{
  function bool CanPickSomethingUp()
  {
    return False;
  }
  
  function bool PlayHarryMovementAnims()
  {
    return False;
  }
  
  function BeginState()
  {
    harry(Owner).HarryAnimType =  AT_Combine;
  }
  
 begin:
  PlayAnim(harry(Owner).HarryAnims[harry(Owner).HarryAnimSet].Jump,,0.1);
  FinishAnim();
  harry(Owner).HarryAnimType =  AT_Replace;
  if ( harry(Owner).PlayerIsAiming() )
  {
    GotoState('stateCasting');
  } else {
    GotoState('stateIdle');
  }
}

function DoDrinkWiggenwell()
{
  if (  !IsInState('stateDrinkWiggenwell') )
  {
    GotoState('stateDrinkWiggenwell');
  }
}

state stateDrinkWiggenwell
{
  function BeginState()
  {
    harry(Owner).HarryAnimType =  AT_Combine;
    harry(Owner).fTimeLastDrank = Level.TimeSeconds;
    bAnimNotReplaceable = True;
  }
  
  function EndState()
  {
    propTemp.bHidden = True;
    harry(Owner).DropCarryingActor();
    propTemp.Destroy();
    bAnimNotReplaceable = False;
    harry(Owner).managerStatus.GetStatusGroup(Class'StatusGroupPotions').IncrementCount(Class'StatusItemWiggenwell',-1);
    harry(Owner).AddHealth(100);
    harry(Owner).PlaySound(Sound'health_boost1', SLOT_None);
  }
  
 begin:
  propTemp = HProp(FancySpawn(Class'WWellGreenBottle',harry(Owner),,,harry(Owner).Rotation));
  harry(Owner).ActorToCarry = propTemp;
  harry(Owner).AttachCarryActor('bip01 L Forearm');
  PlayAnim('DrinkPotion',,[TweenTime]0.4);
  Sleep(0.5);
  switch (Rand(3))
  {
    case 0:
    harry(Owner).PlaySound(Sound'gulping2', SLOT_None);
    break;
    case 1:
    harry(Owner).PlaySound(Sound'gulping3', SLOT_None);
    break;
    case 2:
    harry(Owner).PlaySound(Sound'gulping4', SLOT_None);
    break;
    default:
    harry(Owner).ClientMessage("Warning: random gulp not working right");
    harry(Owner).PlaySound(Sound'gulping2', SLOT_None);
    break;
  }
  FinishAnim();
  harry(Owner).HarryAnimType =  AT_Replace;
  if ( harry(Owner).PlayerIsAiming() )
  {
    GotoState('stateCasting');
  } else {
    GotoState('stateIdle');
  }
}

function DoSleepyJump()
{
  if (  !IsInState('stateSleepyJump') )
  {
    GotoState('stateSleepyJump');
  }
}

state stateSleepyJump
{
  function bool CanPickSomethingUp()
  {
    return False;
  }
  
  function bool PlayHarryMovementAnims()
  {
    return False;
  }
  
  function BeginState()
  {
    harry(Owner).HarryAnimType =  AT_Combine;
  }
  
 begin:
  PlayAnim(harry(Owner).HarryAnims[harry(Owner).HarryAnimSet].Jump,,0.1);
  FinishAnim();
  harry(Owner).HarryAnimType =  AT_Replace;
  if ( harry(Owner).PlayerIsAiming() )
  {
    GotoState('stateCasting');
  } else {
    GotoState('stateIdle');
  }
}

function DoWebJump()
{
  if (  !IsInState('stateWebJump') )
  {
    GotoState('stateWebJump');
  }
}

state stateWebJump
{
  function bool CanPickSomethingUp()
  {
    return False;
  }
  
  function bool PlayHarryMovementAnims()
  {
    return False;
  }
  
  function BeginState()
  {
    harry(Owner).HarryAnimType =  AT_Combine;
  }
  
 begin:
  PlayAnim(harry(Owner).HarryAnims[harry(Owner).HarryAnimSet].Jump,,0.1);
  FinishAnim();
  harry(Owner).HarryAnimType =  AT_Replace;
  if ( harry(Owner).PlayerIsAiming() )
  {
    GotoState('stateCasting');
  } else {
    GotoState('stateIdle');
  }
}

function DoReactRictusempra()
{
  if (  !IsInState('stateReactRictusempra') )
  {
    GotoState('stateReactRictusempra');
  }
}

state stateReactRictusempra
{
  function BeginState()
  {
    harry(Owner).HarryAnimType =  AT_Combine;
	// DD39: Wear off spell Charge Light.
	baseWand(harry(Owner).Weapon).WearOffChargeLight();
  }
  
 begin:
  PlayAnim('react_rictusempra',,[TweenTime]0.3);
  FinishAnim();
  harry(Owner).HarryAnimType =  AT_Replace;
  if ( harry(Owner).PlayerIsAiming() )
  {
    harry(Owner).StopAiming();
  }
  GotoState('stateIdle');
}

function DoReactMimbleWimble()
{
  if (  !IsInState('stateReactMimbleWimble') )
  {
    GotoState('stateReactMimbleWimble');
  }
}

state stateReactMimbleWimble
{
  function BeginState()
  {
    harry(Owner).HarryAnimType =  AT_Combine;
	// DD39: Wear off spell Charge Light.
	baseWand(harry(Owner).Weapon).WearOffChargeLight();
  }
  
 begin:
  PlayAnim('mimblewimble',,[TweenTime]0.3);
  FinishAnim();
  harry(Owner).HarryAnimType =  AT_Replace;
  if ( harry(Owner).PlayerIsAiming() )
  {
    harry(Owner).StopAiming();
  }
  GotoState('stateIdle');
}

