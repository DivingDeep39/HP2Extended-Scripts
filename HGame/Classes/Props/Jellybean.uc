//================================================================================
// Jellybean.
//================================================================================

class Jellybean extends HProp;

var() Sound good;
var() Sound Bad;
var float fPickupFlyTime;
var(JellyBeand) bool bFallsToGround;
var int iSkinTexture;
var bool bInitialized;
//DD39: adding a string to set the global key
var() string GlobalJellybeanKey;

function PreBeginPlay()
{
  Super.PreBeginPlay();
  if (  !bInitialized )
  {
    iSkinTexture = Rand(17);
    bInitialized = True;
  }
  switch (iSkinTexture)
  {
    case 0:
    Skin = Texture'skBeanBlueSpotTex0';
    break;
    case 1:
    Skin = Texture'skJellybeanTex0';
    break;
    case 2:
    Skin = Texture'skBeanBlackTex0';
    break;
    case 3:
    Skin = Texture'skBeanPurpleTex0';
    break;
    case 4:
    Skin = Texture'skBeanRedTex0';
    break;
    case 5:
    Skin = Texture'skBeanDarkGreenTex0';
    break;
    case 6:
    Skin = Texture'skBeanBogieTex0';
    break;
    case 7:
    Skin = Texture'skBlueJellyBeanTex0';
    break;
    case 8:
    Skin = Texture'skGreenJellyBeanTex0';
    break;
    case 9:
    Skin = Texture'skGreenPurpleCheckerBeanTex0';
    break;
    case 10:
    Skin = Texture'skSpottedJellyBeanTex0';
    break;
    case 11:
    Skin = Texture'skRedBlackStripeBeanTex0';
    break;
    case 12:
    Skin = Texture'skBeanBrownTex0';
    break;
    case 13:
    Skin = Texture'skBeanDkBlueTex0';
    break;
    case 14:
    Skin = Texture'skBeanMauveTex0';
    break;
    case 15:
    Skin = Texture'skBeanOrngeTex0';
    break;
    case 16:
    Skin = Texture'skBeanYellowyTex0';
    break;
    default:
  }
}

//DD39: added PostBeginPlay to check for the global key to get
event PostBeginPlay()
{
  Super.PostBeginPlay();
  CheckGlobalJellybeanKey();
}

//DD39: added function to set the global key
function SetGlobalJellybeanKey()
{
	if (GlobalJellybeanKey != "")
		{
			SetGlobalBool(GlobalJellybeanKey,true);
		}
}

//DD39: added function to get the global key
function CheckGlobalJellybeanKey()
{
	if (GetGlobalBool(GlobalJellybeanKey))
	{
		Destroy();
	}	
}

//DD39: calling function from HProp to add function to get the global key
function DoPickupProp()
{
  Super.DoPickupProp();
  SetGlobalJellybeanKey();
}

function Touch (Actor Other)
{
  Super.Touch(Other);
  if ( Other.IsA('Tut1Gnome') )
  {
    PlaySound(soundPickup);
    Destroy();
  }
}

auto state BounceIntoPlace
{
  function BeginState()
  {
    if ( bFallsToGround )
    {
      // SetPhysics(2);
	  SetPhysics(PHYS_Falling);
    } else {
      // SetPhysics(0);
	  SetPhysics(PHYS_None);
    }
  }
  
}

defaultproperties
{
    bFallsToGround=True

    soundPickup=Sound'HPSounds.Magic_sfx.pickup11'

    bPickupOnTouch=True

    EventToSendOnPickup=JellyBeanPickupEvent

    // PickupFlyTo=2
	PickupFlyTo=FT_HudPosition

    classStatusGroup=Class'StatusGroupJellybeans'

    classStatusItem=Class'StatusItemJellybeans'

    bBounceIntoPlace=True

    soundBounce=Sound'HPSounds.Magic_sfx.bean_bounce'

    // Physics=1
	Physics=PHYS_Walking

    bPersistent=True

    Mesh=SkeletalMesh'HProps.skJellybeanMesh'

    AmbientGlow=200

    CollisionRadius=32.00

    CollisionHeight=10.00

    bBlockActors=False

    bBlockPlayers=False

    bProjTarget=False

    bBlockCamera=False

    bBounce=True
	
	//DD39: now it spins
	bRotateToDesired=False
}
