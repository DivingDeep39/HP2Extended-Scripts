//================================================================================
// DD39CarBoostBar.
//================================================================================

class DD39CarBoostBar extends HudItemManager;

const strBAR_EMPTY = "ExtendedAdvFC_Textures.BoostBarEmpty";
//const strBAR_WHITE = "HP2_Menu.Hud.HP2QuidditchBarWhite";
const strBAR_WHITE = "ExtendedAdvFC_Textures.BoostBarWhite";
const fBAR_W = 117.0;
const fBAR_H = 20.0;
const fBAR_START_X = 4.5;
const fBAR_START_Y = 52.0;
const fSCREEN_OVER_FROM_RIGHT_X = 132.0;
const fSCREEN_UP_FROM_BOTTOM_Y = 80.0;
var Texture textureBarEmpty;
var Texture textureBarWhite;
var bool bRegisteredWithHud;

var FlyingFordDirector Director;
var FlyingCarHarry PlayerHarry;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    textureBarEmpty = Texture(DynamicLoadObject(strBAR_EMPTY, class'Texture'));
    textureBarWhite = Texture(DynamicLoadObject(strBAR_WHITE, class'Texture'));
	
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
    Log("Director has called Show() on CarBoostBar");
	if(bShow)
    {
		GotoState('DisplayBoostBar');
    }
    else
    {
        GotoState('Idle');
    }
}

event Destroyed()
{
    HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterCarBoostBar(None);
	
	// DivingDeep39: Omega
	HPHud(HUD).RegisterCarBoostBar(None);
	
    Super.Destroyed();
}

function Color GetBarDrawColor()
{
    local Color colorRet;
    local float ratio;

    //if( !bGreyBar )
	if ( PlayerHarry.bBoostExpired || PlayerHarry.IsInState('stateShock') )
    {
        colorRet.R = 135;
        colorRet.G = 135;
        colorRet.B = 135;
    }
    else
    {
		colorRet.R = 210;
        colorRet.G = 145;
        colorRet.B = 0;
    }
    return colorRet;
}

auto state Idle
{    
}

state DisplayBoostBar
{
    event BeginState()
	{
		Log("Boost Bar is displaying");
	}
	
	event Tick(float fDelta)
    {
        if(!bRegisteredWithHud)
        {
            if(Level.PlayerHarryActor.myHUD != None)
            {
                // DivingDeep39: Omega: HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterQuidditchBar(self);
				
				// DivingDeep39: Omega
				CheckHUDReferences();
				HPHud(HUD).RegisterCarBoostBar(self);
				
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
	
    function RenderHudItemManager(Canvas Canvas, bool bMenuMode, bool bFullCutMode, bool bHalfCutMode)
    {
		//DrawChargeBar(Canvas Canvas,nCurrX,nCurrY, float fScaleFactor)
		
		// DivingDeep39: local float fScaleFactor, fIconX, fIconY, fFullRatio, fSegmentWidth;
		// DivingDeep39: Omega:
		local float fScaleFactor, fFullRatio, fSegmentWidth, fScaleWithoutH, fChargeAmount;
		
		// Omega: Define as ints, not floats
        local int fIconX, fIconY;

        local Color colorSave;
		
		// DivingDeep39: Omega:
		CheckHUDReferences();

        colorSave = Canvas.DrawColor;
		
		// DivingDeep39: Omega:
		fScaleWithoutH = GetScaleFactor(Canvas);
		
        fScaleFactor = GetScaleFactor(Canvas) * Class'M212HScale'.Static.CanvasGetHeightScale(Canvas);
		
        // DivingDeep39: fIconX = Canvas.SizeX - (fScaleFactor * fSCREEN_OVER_FROM_RIGHT_X);
		// Omega: Fix the X size being dependent on height a bit
        fIconX = Canvas.SizeX - (fScaleWithoutH * fSCREEN_OVER_FROM_RIGHT_X);
		
        fIconY = Canvas.SizeY - (fScaleFactor * fSCREEN_UP_FROM_BOTTOM_Y);
		
		// Omega: Apply alignment and then the HUD scale
		AlignXToRight(Canvas, fIconX);
		fIconX = ApplyHUDScale(Canvas, fIconX);
		
        Canvas.SetPos(fIconX, fIconY);
        Canvas.DrawIcon(textureBarEmpty, fScaleFactor);
		
		fChargeAmount = PlayerHarry.GetCurBoostCharge();
		
        fFullRatio = fChargeAmount / 1.0;
        fFullRatio = FClamp(fFullRatio, 0.0, 1.0);
		
        Canvas.DrawColor = GetBarDrawColor();
        fSegmentWidth = fFullRatio * fBAR_W;
        Canvas.SetPos(fIconX + (fBAR_START_X * fScaleFactor), fIconY + (fBAR_START_Y * fScaleFactor));
		
        Canvas.DrawTile(textureBarWhite, fSegmentWidth * fScaleFactor, textureBarWhite.VSize * fScaleFactor, 0.0, 0.0, fSegmentWidth, textureBarWhite.VSize);

        Canvas.DrawColor = colorSave;
    }

    event EndState()
    {
        bRegisteredWithHud = false;
        HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterCarBoostBar(None);
    }
}

//managed to get these out of UTPT -AdamJD
defaultproperties
{
	bHidden=True
	
	DrawType=DT_Sprite
}