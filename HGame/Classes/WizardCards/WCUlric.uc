//================================================================================
// WCUlric.
//================================================================================

class WCUlric extends BronzeCards;

//texture imports -AdamJD
#exec Texture Import File=Textures\Icons\WizCardUricBigTexture.PNG	GROUP=Icons	Name=WizCardUricBigTexture COMPRESSION=P8 UPSCALE=1 Mips=0 Flags=2
#exec Texture Import File=Textures\Skins\WizardCardUricTex0.PNG	GROUP=Skins	Name=WizardCardUricTex0 COMPRESSION=3 UPSCALE=1 Mips=1 Flags=0

function PostBeginPlay()
{
  WizardName = "Uric the Oddball";
  Super.PostBeginPlay();
}

defaultproperties
{
    Id=18

    textureBig=Texture'HGame.Icons.WizCardUricBigTexture'

    strDescriptionId="WizCard_0056"

    Skin=Texture'HGame.Skins.WizardCardUricTex0'

}
