//================================================================================
// spellLumos.
//================================================================================

class spellLumos extends baseSpell;

function bool OnSpellHitHPawn (Actor aHit, Vector vHitLocation)
{
  return HPawn(aHit).HandleSpellLumos(self,vHitLocation);
}

auto state stateIdle
{
begin:
  GotoState('StateFlying');
}

state StateFlying
{
  function BeginState()
  {
    Velocity = vector(Rotation) * Speed;
    Acceleration = Velocity;
    PlayerHarry.ClientMessage("Lumos: BeginState() StateFlyingToTarget");
  }
  
  event Tick (float fTimeDelta)
  {
    Super.Tick(fTimeDelta);
    UpdateRotationWithSeeking(fTimeDelta);
    if ( fxFlyParticleEffect != None )
    {
      fxFlyParticleEffect.SetLocation(Location);
    }
  }
  begin:
}

defaultproperties
{
    // SpellType=4
	SpellType=SPELL_Lumos

    SpellIcon=None

    SeekSpeed=5.00

    fxFlyParticleEffectClass=Class'HPParticle.Lumos_fly'

    fxHitParticleEffectClass=Class'DD39Lumos_hit'

    SpellIncantation="spells3"

    QuietSpellIncantation="spells4"

    Speed=400.00

    // DrawType=0
	DrawType=DT_None
	
	//DD39: brightness change
	LightBrightness=400
	
	//DD39: hue change
	LightHue=32
	
	//DD39: radius changes
	LightRadius=8
}
