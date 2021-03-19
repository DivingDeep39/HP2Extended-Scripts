//================================================================================
// Diffindo_Fly.
//================================================================================

class Diffindo_Fly extends AllSpellCast_FX;

//texture package import -AdamJD
#exec OBJ LOAD FILE=..\Textures\HP_FX.utx 		Package=HPParticle.hp_fx

defaultproperties
{
    ParticlesPerSec=(Base=14.00,Rand=0.00)

    SourceWidth=(Base=0.00,Rand=0.00)

    SourceHeight=(Base=0.00,Rand=0.00)

    AngularSpreadWidth=(Base=0.00,Rand=0.00)

    AngularSpreadHeight=(Base=0.00,Rand=0.00)

    bSteadyState=True

    Speed=(Base=40.00,Rand=0.00)

    Lifetime=(Base=1.50,Rand=0.00)

    ColorStart=(Base=(R=121,G=255,B=11,A=0),Rand=(R=0,G=0,B=0,A=0))

    ColorEnd=(Base=(R=0,G=0,B=0,A=0),Rand=(R=0,G=0,B=0,A=0))

    SizeWidth=(Base=16.00,Rand=0.00)

    SizeLength=(Base=16.00,Rand=0.00)

    SpinRate=(Base=1.00,Rand=8.00)

    Textures=Texture'HPParticle.hp_fx.Particles.Les_Sparkle_03'

    Physics=PHYS_Rotating

    bFixedRotationDir=True

    RotationRate=(Pitch=50000,Yaw=0,Roll=0)
}