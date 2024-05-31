//================================================================================
// DD39CarHealthBar.
//================================================================================

class DD39CarHealthBar extends HudItemManager;

const strBAR_EMPTY= "HP2_Menu.Icon.HP2EnemyHealthEmpty";
const strBAR_CAR = "ExtendedAdvFC_Textures.CarHealthBar";
const fBAR_W = 116.0;
const fBAR_H = 20.0;
const fBAR_START_X = 5.0;
const fBAR_START_Y = 83.0;
const fSCREEN_X= 4;
const fSCREEN_UP_FROM_BOTTOM_Y = 110.0;
var Texture textureBarFull;
var Texture textureBarEmpty;
var bool bRegisteredWithHud;

var FlyingFordDirector Director;
var FlyingCarHarry PlayerHarry;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    textureBarEmpty = Texture(DynamicLoadObject(strBAR_EMPTY,Class'Texture'));
    textureBarFull = Texture(DynamicLoadObject(strBAR_CAR,Class'Texture'));
	
	// DivingDeep39: Omega
	CheckHUDReferences();
	
	/*foreach AllActors(Class'FlyingFordDirector',Director)
	{
		break;
	}*/
	
	foreach AllActors(Class'FlyingCarHarry',PlayerHarry)
	{
		break;
	} 
}

function Show(bool bShow)
{
    Log("Director has called Show() on DisplayCarHealth");
	if(bShow)
    {
		GotoState('DisplayCarHealth');
    }
    else
    {
        GotoState('Idle');
    }
}

function End()
{
	HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterCarHealthBar(None);
	bRegisteredWithHud = False;
	GotoState('Idle');
}

event Destroyed()
{
    HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterCarHealthBar(None);
	
	// DivingDeep39: Omega
	HPHud(HUD).RegisterCarHealthBar(None);
	
    Super.Destroyed();
}

auto state Idle
{    
}

state DisplayCarHealth
{
    event BeginState()
	{
		Log("Health Bar is displaying");
	}
	
	event Tick(float fDelta)
    {
        if(!bRegisteredWithHud)
        {
            if(Level.PlayerHarryActor.myHUD != None)
            {
				CheckHUDReferences();
				
				HPHud(HUD).RegisterCarHealthBar(self);
				
                bRegisteredWithHud = true;
            }
        }
		
		if ( baseHUD(PlayerHarry.myHUD).bCutSceneMode == True )
		{
			return;
		}
		
		if ( baseHUD(PlayerHarry.myHUD).bCutPopupMode == True )
		{
			return;
		}
    }
	
	function RenderHudItemManager (Canvas Canvas, bool bMenuMode, bool bFullCutMode, bool bHalfCutMode)
	{
		local float fScaleFactor;
		
		// DivingDeep39: local float fIconX;
		// DivingDeep39: local float fIconY;
		
		// Omega: Auto-casting not supported by out vars... again
		local int fIconX;
		local int fIconY;
		
		local float fCarHealth;
		local float fEmptyHealth;
		local float fSegmentWidth;
		
		// DivingDeep39: Omega
		CheckHUDReferences();
  
		fScaleFactor = GetScaleFactor(Canvas) * Class'M212HScale'.Static.CanvasGetHeightScale(Canvas);
		fIconX = fSCREEN_X * fScaleFactor;
		fIconY = Canvas.SizeY - fScaleFactor * fSCREEN_UP_FROM_BOTTOM_Y;
		
		// Omega: Apply alignment and then the HUD scale
		AlignXToLeft(Canvas, fIconX);
		fIconX = ApplyHUDScale(Canvas, fIconX);
		
		Canvas.SetPos(fIconX,fIconY);
		Canvas.DrawIcon(textureBarFull,fScaleFactor);
		fCarHealth = PlayerHarry.GetCarHealth() / 100;
		fCarHealth = FClamp(fCarHealth,0.0,1.0);
		fEmptyHealth = 1.0 - fCarHealth;
		fSegmentWidth = fCarHealth * fBAR_W;
		Canvas.SetPos(fIconX + (fBAR_START_X * fScaleFactor), fIconY + (fBAR_START_Y * fScaleFactor));
		Canvas.DrawTile(textureBarEmpty,fSegmentWidth * fScaleFactor,textureBarEmpty.VSize * fScaleFactor,0.0,0.0,fSegmentWidth,textureBarEmpty.VSize);
		if ( fCarHealth <= 0.0 )
		{
			End();
		}
	}
}

//managed to get these out of UTPT -AdamJD
defaultproperties
{
	bHidden=True
	
	DrawType=DT_Sprite
}