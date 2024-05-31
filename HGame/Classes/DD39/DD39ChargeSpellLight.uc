class DD39ChargeSpellLight extends HiddenHPawn;

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

	LightEffect=LE_NonIncidence
			
	LightType=LT_Steady
}