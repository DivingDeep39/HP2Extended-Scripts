//================================================================================
// DD39AragogColObjBlk.
//================================================================================

class DD39AragogColObjBlk extends GenericColObj;

function bool HandleSpellFlipendo (optional baseSpell spell, optional Vector vHitLocation)
{
}

function Touch (Actor Other)
{
}

defaultproperties
{
	bBlockPlayers=True
	
	bProjTarget=False
	
	CollisionHeight=90.00
	
	CollisionRadius=98.00
	
	DrawType=DT_Sprite
}