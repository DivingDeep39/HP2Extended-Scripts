//================================================================================
// MuggleMeterManager.
//================================================================================

//this is an unused file -AdamJD

class MuggleMeterManager extends HudItemManager;

var bool bRegisteredWithHud;
var FlyingFordDirector Director;
var FlyingCarHarry PlayerHarry;

const strBAR_EMPTY= "HP2_Menu.Hud.HP2MagicStrengthEmpty";
const strBAR_FULL= "ExtendedAdvFC_Textures.MuggleMeterFull";
const strSLIDER= "ExtendedAdvFC_Textures.MuggleMeterSlider";
const strSLIDERSIGHT= "ExtendedAdvFC_Textures.MuggleMeterSliderSighted";

const fBAR_H= 128.0;
const fBAR_W= 36.0;
//const fBAR_Y= 25.0;
const fBAR_Y= 192.0;
const fBAR_X= 25.0;

var int TOP_OFFSET;
var int BOTTOM_OFFSET;

const fSLIDER_POINTER_YOFFSET= 66;
const fSLIDER_W= 128;

var Texture textureSlider;
var Texture textureSliderSighted;
var Texture textureBarEmpty;
var Texture textureBarFull;

//const fSCREEN_UP_FROM_BOTTOM_Y = 110.0;
//const fSCREEN_X= 4;
//const fBAR_START_X = 25.0;
//const fBAR_START_Y = 25.0;


event PostBeginPlay()
{
    Super.PostBeginPlay();
    textureBarEmpty = Texture(DynamicLoadObject(strBAR_EMPTY,Class'Texture'));
    textureBarFull = Texture(DynamicLoadObject(strBAR_FULL,Class'Texture'));
	textureSlider = Texture(DynamicLoadObject(strSLIDER,Class'Texture'));
	textureSliderSighted = Texture(DynamicLoadObject(strSLIDERSIGHT,Class'Texture'));
	
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
    Log("Director has called Show() on DisplayMuggleMeter");
	if(bShow)
    {
		GotoState('DisplayMuggleMeter');
    }
    else
    {
        GotoState('Idle');
    }
}

function PlayMeterSound()
{
	PlaySound(Sound'ExtendedAdvFC_Sounds.MuggleMeterSFX',SLOT_None,,,1024.00);
}

event Destroyed()
{
    HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterMuggleMeter(None);
	
	// DivingDeep39: Omega
	HPHud(HUD).RegisterMuggleMeter(None);
	
    Super.Destroyed();
}

function Color GetBarDrawColor()
{
	local Color colorRet;
	local float ratio;

	if ( PlayerHarry.GetSightLevel() <= 25.00 )
	{
		colorRet.R = 25;
		colorRet.G = 175;
		colorRet.B = 44;
	}
	else if ( PlayerHarry.GetSightLevel() <= 50.00 )
	{
		colorRet.R = 210;
		colorRet.G = 145;
		colorRet.B = 0;
	}
	else if ( PlayerHarry.GetSightLevel() <= 75.00 )
	{
		colorRet.R = 225;
		colorRet.G = 90;
		colorRet.B = 0;
	}
	else
	{
		colorRet.R = 255;
		colorRet.G = 0;
		colorRet.B = 0;
	}
	return colorRet;
}

auto state Idle
{
}

state DisplayMuggleMeter
{
	event BeginState()
	{
		Log("Muggle Meter is displaying");
	}
	
	event Tick(float fDelta)
    {
        if(!bRegisteredWithHud)
        {
            if(Level.PlayerHarryActor.myHUD != None)
            {
				CheckHUDReferences();
				
				HPHud(HUD).RegisterMuggleMeter(self);
				
                bRegisteredWithHud = true;
            }
        }
		
		if ( baseHUD(PlayerHarry.myHUD).bCutSceneMode == True )
		{
			return;
		}
		
		/*if ( baseHUD(PlayerHarry.myHUD).bCutPopupMode == True )
		{
			return;
		}*/
    }
  
	function RenderHudItemManager (Canvas Canvas, bool bMenuMode, bool bFullCutMode, bool bHalfCutMode)
	 {
		local float fScaleFactor;
		
		//local float fBarScaledX;
		//local float fBarScaledY;
		
		local int fBarScaledX;
		local int fBarScaledY;
		
		local float fSliderX;
		local float fSliderY;
		local float fBarEmptyH;
		
		local float fSightLevel;
		
		local float fSegmentHeight;
		local float fSegmentStartAt;
		
		local float UScale;
		local float VScale;
		
		// Metallicafan212:	Icon scale
		local float XScale;
		local float YScale;
		
		local int nTotalOffsets;
		local int nSliderOffset;
		
		local Color colorSave;
	  
		//fScaleFactor = GetScaleFactor(Canvas);
		
		CheckHUDReferences();
		
		colorSave = Canvas.DrawColor;
	  
		fScaleFactor = GetScaleFactor(Canvas) * Class'M212HScale'.Static.CanvasGetHeightScale(Canvas);
		
		fBarScaledX = fBAR_X * fScaleFactor;
		fBarScaledY = fBAR_Y * fScaleFactor;
		
		// Omega: Apply alignment and then the HUD scale
		AlignXToLeft(Canvas, fBarScaledX);
		fBarScaledX = ApplyHUDScale(Canvas, fBarScaledX);
		
		Canvas.SetPos(fBarScaledX,fBarScaledY);
		Canvas.DrawIcon(textureBarEmpty,fScaleFactor);
		
		///////////////////////////////////////////////////
		
		fSegmentHeight = 0.0;
		fSegmentStartAt = 0.0;
		TOP_OFFSET = 5;
		BOTTOM_OFFSET = 6;
		nTotalOffsets = TOP_OFFSET + BOTTOM_OFFSET;
		nSliderOffset = 2;
		XScale = 128.0;
		YScale = 128.0;
		
		fSightLevel = PlayerHarry.GetSightLevel() / 100.00;
		fSightLevel = FClamp(fSightLevel,0.0,1.0);
		
		Canvas.DrawColor = GetBarDrawColor();

		fBarEmptyH = fSightLevel * fBAR_H;
		
		if ( fSightLevel > 0 )
		{		
			// Metallicafan212:	For moving it down
			UScale = XScale / textureBarFull.USize;
			VScale = YScale / textureBarFull.VSize;
		
			fSegmentHeight 		= fSightLevel * ((textureBarFull.VSize * VScale) - nTotalOffsets);
			fSegmentStartAt 	= (textureBarFull.VSize * VScale) - BOTTOM_OFFSET - fSegmentHeight;
			fSegmentHeight 	   += BOTTOM_OFFSET;
			
			Canvas.SetPos(fBarScaledX, fBarScaledY + fSegmentStartAt * fScaleFactor);			
			
			Canvas.DrawTile(textureBarFull, textureBarFull.USize * fScaleFactor * UScale, fSegmentHeight * fScaleFactor, 0.0, fSegmentStartAt / VScale, textureBarFull.USize, fSegmentHeight / VScale);
		}
		
		/*Canvas.SetPos(fBarScaledX,fBarScaledY);
		Canvas.DrawTile(textureBarFull,textureBarFull.USize * fScaleFactor,fBarEmptyH * fScaleFactor,0.0,0.0,textureBarFull.USize,fBarEmptyH);*/
		
		Canvas.DrawColor = colorSave;
		
		////////////////////////////////////////////////////
		
		//fSliderX = fBarScaledX - (((fSLIDER_W - fBAR_W) / 2) * fScaleFactor);
		fSliderX = fBarScaledX - ((((fSLIDER_W - fBAR_W) / 2) + nSliderOffset) * fScaleFactor);
		//fSliderY = ( fBAR_Y + fBarEmptyH - fSLIDER_POINTER_YOFFSET) * fScaleFactor;
		fSliderY = ( (fBAR_Y + 128.0) + (fBarEmptyH * (-1)) - fSLIDER_POINTER_YOFFSET) * fScaleFactor;
		Canvas.SetPos(fSliderX,fSliderY);
		if ( PlayerHarry.GetSightLevel() <= 75.00 )
		{
			Canvas.DrawIcon(textureSlider,fScaleFactor);
		}
		else
		{
			Canvas.DrawIcon(textureSliderSighted,fScaleFactor);
		}
	 }
  
	event EndState()
	{
		HPHud(harry(Level.PlayerHarryActor).myHUD).RegisterMuggleMeter(None);
		bRegisteredWithHud = False;
		GotoState('Idle');
	}

}

defaultproperties
{
    bHidden=True

    // DrawType=1
	DrawType=DT_Sprite
}
