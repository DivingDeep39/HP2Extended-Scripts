//================================================================================
// DD39Fordtrail.
//================================================================================

class DD39Fordtrail extends ParticleFX;

#exec OBJ LOAD FILE=..\Textures\HP_FX.utx 		Package=HPParticle.hp_fx

defaultproperties
{
    ParticlesPerSec=(Base=15.00,Rand=5.00)

    SourceWidth=(Base=20)

    SourceHeight=(Base=10)

    SourceDepth=(Base=0)

    Speed=(Base=10.00,Rand=15.00)

    Lifetime=(Base=1.00,Rand=1.00)

    ColorStart=(Base=(R=128,G=255,B=255))
	
	ColorEnd=(Base=(R=0,B=255))

    SizeWidth=(Base=5,Rand=2)

    SizeLength=(Base=5,Rand=2)
	
	Chaos=0.75

    ChaosDelay=1.00

    Damping=0.75
	
	Textures(0)=Texture'HPParticle.hp_fx.Particles.flare4'

    bEmit=False
}
