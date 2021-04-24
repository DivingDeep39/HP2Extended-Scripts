//================================================================================
// FireHP2.
//================================================================================

class FireHP2 extends ParticleFX;

//texture package import -AdamJD
#exec OBJ LOAD FILE=..\Textures\HP_FX.utx 		Package=HPParticle.hp_fx

defaultproperties
{
    ParticlesPerSec=(Base=15.00,Rand=10.00)

    SourceWidth=(Base=4.00,Rand=1.00)

    SourceHeight=(Base=4.00,Rand=1.00)

    Speed=(Base=10.00,Rand=15.00)

    Lifetime=(Base=1.00,Rand=2.00)

    SizeWidth=(Base=12.00,Rand=4.00)

    SizeLength=(Base=12.00,Rand=4.00)

    SizeEndScale=(Base=-1.00,Rand=2.00)

    SpinRate=(Base=-2.00,Rand=4.00)

    Chaos=1.00

    ChaosDelay=1.00

    Textures(0)=Texture'HPParticle.hp_fx.Spells.Les_fire_01'

    AmbientSound=Sound'HPSounds.General.torch01'

    Rotation=(Pitch=16384,Yaw=0,Roll=0)

    SoundRadius=16

    SoundVolume=96
}
