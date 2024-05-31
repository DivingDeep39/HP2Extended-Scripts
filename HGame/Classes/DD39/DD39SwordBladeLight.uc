//================================================================================
// DD39SwordBladeLight.
//================================================================================

class DD39SwordBladeLight extends HiddenHPawn;

var bool bTimeUp;
var float Alpha;
var float CurTime;
var float TotalTime;
var byte StartingBrightness;
var byte EndingBrightness;

var bool bWearOff;
var float WearTime;

event PostBeginPlay()
{
  Super.PostBeginPlay();
  StartingBrightness = 0;
  EndingBrightness = 201;
}

event Tick(float DeltaTime)
{
  if ( !bTimeUp )
  {
    CurTime = fclamp(CurTime + DeltaTime/TotalTime, 0.0, 1.0);
    LightBrightness = Lerp(EaseOut(CurTime), StartingBrightness, EndingBrightness);
  
    if ( CurTime == 1.0 )
    {
      bTimeUp = True;
    }
  }
  
  if ( bWearOff )
  {
    CurTime = fclamp(CurTime + DeltaTime/WearTime, 0.0, 1.0);
    LightBrightness = Lerp(EaseOut(CurTime), StartingBrightness, EndingBrightness);
  
    if ( CurTime == 1.0 )
    {
      Destroy();
    }
  }
}

function float Flip(float F)
{
  return 1 - F;
}

function float EaseOut(float F)
{
  return Flip(Flip(F) ** 2);
}

function DoWearOff()
{
   bTimeUp = True;
   StartingBrightness = LightBrightness;
   EndingBrightness = 0;
   bWearOff = True;
}

defaultproperties
{
    Alpha=0.0;
	
	TotalTime=3.00
	
	WearTime=0.5
	
	LightBrightness=0
	
	LightHue=22
	
	LightSaturation=100

	LightRadius=15
	
	LightRadiusInner=50
	
	LightEffect=LE_NonIncidence
	
	LightType=LT_Steady
}
