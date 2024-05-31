//================================================================================
// DD39Justin.
//================================================================================

class DD39Justin extends Characters;

defaultproperties
{
	CollisionHeight=42
	
	CollisionRadius=15
	
	AmbientGlow=75
	
	DrawScale=1.05
	
	Mesh=SkeletalMesh'HPModels.skhp2_genmale2Mesh'
	
	Skins(0)=Texture'Extended_Textures.Models.skJustinTex0'
	
	Skins(1)=Texture'Extended_Textures.Models.skJustinTex1'
	
    GroundRunSpeed=220.00
	
	GroundSpeed=150.00
	
	Physics=PHYS_Walking
}