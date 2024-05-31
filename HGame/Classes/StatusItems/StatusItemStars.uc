//================================================================================
// StatusItemStars.
//================================================================================

class StatusItemStars extends StatusItem;

//DD39: this counts the number of stars in the level and returns the max number
function GetMaxStarsCount()
{ 
    local ChallengeStar Star;
    
	if ( nCount == 0 )
	{
	  nMaxCount = 0;
	  ForEach AllActors(Class'ChallengeStar',Star)
	  {
		nMaxCount++;
	  }
	}
}

defaultproperties
{
    strHudIcon="HP2_Menu.Icons.HP2StarCounter"

    bDisplayCount=True

    bDisplayMaxCount=True

    strToolTipId="InGameMenu_0018"

    bTravelStatus=False
}