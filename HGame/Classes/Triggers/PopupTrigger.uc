//================================================================================
// PopupTrigger.
//================================================================================

class PopupTrigger extends Trigger;

// Dialog vars
var(popup) string dialogID;
// Omega: Added to enable users to do M212Say style localized audio in other packages
var(popup) string LocalizationFile;
var(popup) string Package;
var(popup) string Section;

var(popup) float fPopupDuration;
var(popup) bool bPlayDialogSound;
var(popup) bool bDoNothingIfHarryCaptured;

// Omega: Added to have Harry do it
var(popup) bool bPlayOnHarry;
// Omega: If the dialog ID contains "PC_HRY" we handle it
var(popup) bool bAutoHandleHarryLine;

// Omega: Hack to automatically handle Harry's lines so I don't have to update every fucking map
function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(!bAutoHandleHarryLine)
	{
		return;
	}

	dialogID = Caps(dialogID);
	dialogID = Mid(dialogID, 0);

	if(ParseDelimitedString(dialogID, "_", 2, False) ~= "HRY")
	{
		bPlayOnHarry = True;
	}

	Log(Self $ "Package: " $Package$ " dialog ID: " $LocalizationFile$ "." $dialogID$ " character: " $ParseDelimitedString(dialogID, "_", 2, False)$ " bPlayOnHarry: " $bPlayOnHarry);
}

function Trigger (Actor Other, Pawn EventInstigator)
{
  	Activate(Other,EventInstigator);
}

function Activate (Actor Other, Pawn Instigator)
{
	if ( bDoNothingIfHarryCaptured && harry(Level.PlayerHarryActor).bIsCaptured )
	{
		return;
	}

	if ( dialogID != "" )
	{
		if(bPlayOnHarry)
		{
			Level.PlayerHarryActor.DeliverLocalizedDialog(dialogID,bPlayDialogSound,fPopupDuration, LocalizationFile, Section, Package);
		}
		else
		{
			DeliverLocalizedDialog(dialogID,bPlayDialogSound,fPopupDuration, LocalizationFile, Section, Package);
		}
	}
}

defaultproperties
{
    bPlayDialogSound=True

    bDoNothingIfHarryCaptured=True

    bTriggerOnceOnly=True

	bAutoHandleHarryLine=True
	
	// DD39: DivingDeep39: Defaults for new vars
	LocalizationFile="HPDialog"
	
	Package="AllDialog"
	
	Section="All"
}
