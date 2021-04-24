//================================================================================
// Avifors_react.
//================================================================================

class Avifors_react extends AllSpellCast_FX;

//texture package import -AdamJD
#exec OBJ LOAD FILE=..\Textures\HP_FX.utx 		Package=HPParticle.hp_fx

defaultproperties
{
    ParticlesPerSec=(Base=1.00,Rand=2.00)

    SourceWidth=(Base=0.50,Rand=0.00)

    SourceHeight=(Base=0.50,Rand=0.00)

    SourceDepth=(Base=5.00,Rand=0.00)

    Speed=(Base=10.00,Rand=0.00)

    Lifetime=(Base=6.00,Rand=0.00)

    ColorStart=(Base=(R=255,G=255,B=255,A=0),Rand=(R=0,G=0,B=0,A=0))

    ColorEnd=(Base=(R=255,G=255,B=255,A=0),Rand=(R=0,G=0,B=0,A=0))

    SpinRate=(Base=1.50,Rand=0.50)

    Chaos=8.00

    ChaosDelay=0.75

    Elasticity=0.50

    Damping=0.75

    GravityModifier=0.00

    ParticlesAlive=8

    ParticlesMax=8

    Textures(0)=Texture'HPParticle.hp_fx.Particles.Feather'

    Style=STY_Masked
}
