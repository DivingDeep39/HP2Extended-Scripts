//================================================================================
// SecretAreaMarker.
//================================================================================

class SecretAreaMarker extends HiddenHPawn;

//texture import -AdamJD
#exec Texture Import File=Textures\SecretTexture.PNG Name=SecretTexture COMPRESSION=3 UPSCALE=1 Mips=1 Flags=2

var() bool bUseCollision;
var bool bFound;
var Sound FoundSound;

function OnFound()
{
	if (  !bFound )
	{
		cm("Secret Area Found!  Oh most glorious delight and joy!!!");
		if ( FoundSound != None )
		{
			PlaySound(FoundSound);
		}
	}
	bFound = True;
}

function PreBeginPlay()
{
	if (  !bUseCollision )
	{
		SetCollision(False,False,False);
	}
}

function Touch (Actor Other)
{
	if ( bUseCollision && Other.IsA('PlayerPawn') )
	{
		OnFound();
	}
}

function Trigger (Actor Other, Pawn EventInstigator)
{
	OnFound();
}

defaultproperties
{
    bUseCollision=True

    FoundSound=Sound'HPSounds.Music_Events.Found_Secret_Music'

    bPersistent=True

    Texture=Texture'HGame.SecretTexture'

    bCollideActors=True

}