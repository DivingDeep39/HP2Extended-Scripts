//================================================================================
// DD39AragogColObjDmg.
//================================================================================

class DD39AragogColObjDmg extends GenericColObj;

var bool bAllowDamage;

event PostBeginPlay()
{
	bAllowDamage = True;
	Super.PostBeginPlay();
}

function bool HandleSpellFlipendo (optional baseSpell spell, optional Vector vHitLocation)
{
}

function Touch (Actor Other)
{
}

event Tick(float dtime)
{
	Super.Tick(dtime);
	
	foreach TouchingActors(Class'harry',PlayerHarry)
	{
		if ( !bAllowDamage )
		{
			return;
		}
		
		if ( PlayerHarry.bIsCaptured )
		{
			return;
		}
		
		bAllowDamage = False;
		PlayerHarry.TakeDamage(15,self,Location,vect(0.00,0.00,0.00),'DD39AragogColObj');
		SetTimer(1.0,False);
	}
}

event Timer()
{
	bAllowDamage = True;
}

defaultproperties
{		
	bAllowDamage=True
	
	bProjTarget=False
	
	CollisionHeight=90.00
	
	CollisionRadius=100.00
	
	DrawType=DT_Sprite
}