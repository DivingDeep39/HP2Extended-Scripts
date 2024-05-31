//================================================================================
// DD39Colin.
//================================================================================

class DD39Colin extends Characters;

defaultproperties
{	
	CollisionHeight=38
	
	CollisionRadius=15
	
	AmbientGlow=75
	
	DrawScale=0.964
	
	DrawScale3D=(X=1.067,Y=1.067,Z=1)
	
	Mesh=SkeletalMesh'HPModels.skhp2_genmale1Mesh'
	
	Skins(0)=Texture'Extended_Textures.Models.skColinTex0'
	
	Skins(1)=Texture'Extended_Textures.Models.skColinTex1'
	
    GroundRunSpeed=220.00
	
	GroundSpeed=200.00
	
	Physics=PHYS_Walking
	
	AvailableAccessories(0)=(AccessoryClass=Class'Extended_Classes.DD39ColinCamera',BoneName="bip01 Spine2",RelativeRotation=(Yaw=15500,Roll=-16384),RelativeLocation=(X=7,Y=-2.2,Z=-1))
}