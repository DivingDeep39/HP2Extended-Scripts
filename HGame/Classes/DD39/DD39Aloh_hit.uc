//================================================================================
// DD39Aloh_hit.
//================================================================================

class DD39Aloh_hit extends Aloh_hit;

var bool bTimeUp;
var float Alpha;
var float CurTime;
var float TotalTime;
var byte StartingBrightness;
var byte EndingBrightness;

event PostBeginPlay()
{
  Super.PostBeginPlay();
  StartingBrightness = LightBrightness;
  EndingBrightness = 0;
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
}

function float Flip(float F)
{
  return 1 - F;
}

function float EaseOut(float F)
{
  return Flip(Flip(F) ** 2);
}

defaultproperties
{
	Alpha=0.0;
	
	TotalTime=1.5
	
	LightBrightness=201
	
	LightHue=37
	
	LightSaturation=72

	LightRadius=5
	
	LightEffect=LE_NonIncidence
	
	LightType=LT_Steady
}