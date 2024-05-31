//================================================================================
// DD39duelRictusempra_hit.
//================================================================================

class DD39duelRictusempra_hit extends duelRictusempra_hit;


var Actor HitActor;
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
  
  if ( HitActor == None )
  {
    return;
  }
  SetLocation(HitActor.Location);
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
	
	TotalTime=1.75
	
	LightBrightness=201
	
	LightHue=2
	
	LightSaturation=72

	LightRadius=5
	
	LightEffect=LE_NonIncidence
	
	LightType=LT_Steady
}
