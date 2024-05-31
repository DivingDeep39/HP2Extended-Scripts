//================================================================================
// StatusItemSecrets.
//================================================================================

class StatusItemSecrets extends StatusItem;

function DrawSpecifiedCount (Canvas Canvas, int nCurrX, int nCurrY, float fScaleFactor, int nLocalCount)
{
	//local string strSecrets;
	local int nNumSecrets;
	local int nNumSecretsFound;
	local SecretAreaMarker Marker;
	
	local Font fontSave;
	local string strCountDisplay;
	local float fXTextLen;
	local float fYTextLen;
	local float fXPos;
	local float fYPos;

	fXTextLen = 0.0;
	fYTextLen = 0.0;
	fontSave = Canvas.Font;
	strCountDisplay = string(nLocalCount);
	if ( bDisplayMaxCount == True )
	{
		//strCountDisplay = strCountDisplay $ "/" $ string(nMaxCount);
		//foreach Root.Console.Viewport.Actor.AllActors(Class'SecretAreaMarker',Marker)
		foreach AllActors(Class'SecretAreaMarker',Marker)
		{
		  nNumSecrets++;
		  
		  if ( Marker.bFound )
		  {
			nNumSecretsFound++;
		  }
		}
		//strSecrets = string(nNumSecretsFound) $ "/" $ string(nNumSecrets);
		strCountDisplay = string(nNumSecretsFound) $ "/" $ string(nNumSecrets);
	}
	Canvas.Font = GetCountFont(Canvas);
	Canvas.TextSize(strCountDisplay, fXTextLen, fYTextLen);
	fXPos = nCurrX + nCountMiddleX * fScaleFactor - fXTextLen / 2;
	
	fYPos = (nCurrY + nCountMiddleY * fScaleFactor - fYTextLen / 2); //* HScale;
	
	if ( fXPos + fXTextLen > Canvas.SizeX )
	{
		fXPos = Canvas.SizeX - (fXTextLen - 2);
	}
	if ( fYPos + fYTextLen > Canvas.SizeY )
	{
		fYPos = Canvas.SizeY - (fYTextLen - 2);
	}
	Canvas.SetPos(fXPos, fYPos);
	Canvas.DrawShadowText(strCountDisplay, GetCountColor(), GetCountColor(True));
	Canvas.Font = fontSave;
}

defaultproperties
{
    strHudIcon="Extended_Textures.Icons.HP2SecretsCounter"

    bDisplayCount=True

    bDisplayMaxCount=True

    strToolTipId="Report_Card_0006"

    bTravelStatus=False
}