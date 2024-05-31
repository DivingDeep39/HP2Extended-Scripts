//================================================================================
// SecretAreaMarker.
//================================================================================

class SecretAreaMarker extends HiddenHPawn;

//texture import -AdamJD
#exec Texture Import File=Textures\SecretTexture.PNG Name=SecretTexture COMPRESSION=P8 UPSCALE=1 Mips=0 Flags=2

var() bool bUseCollision;
var bool bFound;
//DD39: adding a string to set the global key
var() string GlobalSecretKey;
var Sound FoundSound;

function PreBeginPlay()
{
	PlayerHarry = harry(Level.PlayerHarryActor);
	
	if (  !bUseCollision )
	{
		SetCollision(False,False,False);
	}
}

//DD39: added PostBeginPlay to check for the global key to get
event PostBeginPlay()
{
	Super.PostBeginPlay();
	CheckGlobalSecretKey();
}

//DD39: added function to set the global key
function OnFound()
{
	if (  !bFound )
	{
		cm("Secret Area Found!  Oh most glorious delight and joy!!!");
		
		//DD39
		PlayerHarry.managerStatus.IncrementCount(Class'StatusGroupSecrets',Class'StatusItemSecrets',0);
		
		if ( FoundSound != None )
		{
			PlaySound(FoundSound);
		}
		
		if (GlobalSecretKey != "")
		{
			SetGlobalBool(GlobalSecretKey,true);
		}
	}
	bFound = True;
}

//DD39: added function to get the global key
function CheckGlobalSecretKey()
{
	if (GetGlobalBool(GlobalSecretKey))
	{
		OnFoundNoSound();
	}
}

//DD39: adding a function to disable sound when a global key is got
function OnFoundNoSound()
{
	if (  !bFound )
	{
		cm("Secret Area Found!  Oh most glorious delight and joy!!!");
		if ( FoundSound != None )
		{
			StopSound(FoundSound);
		}
	}
	bFound = True;
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