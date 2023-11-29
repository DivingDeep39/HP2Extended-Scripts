// Metallicafan212:	Button that scales the position and size to fit the current screen
class HGameButton based on UWindowButton;

var float WX, WY, WW, WH, XOffset, YOffset;

// Metallicafan212:	These are used to rescale them, as needed
var float OrigX;

// Metallicafan212:	If to stretch to fit
var bool bStretchTex;

var Region		WUpRegion,  WDownRegion,  WDisabledRegion,  WOverRegion;

function float GetDHeightScale()
{
	return Class'M212HScale'.Static.UWindowGetHeightScale(Root) * Class'M212HScale'.Static.UWindowGetHeightScale(Root);
}

function float GetWidthScale()
{
	return (3.0 / 4.0) / (Root.RealHeight / Root.RealWidth);
}

function ResolutionChanged(float W, float H)
{
	Super.ResolutionChanged(W, H);
	
	// Metallicafan212:	Say we were resized
	Resized();
}

function DrawStretchedTextureSegment( Canvas C, float X, float Y, float W, float H, 
									  float tX, float tY, float tW, float tH, texture Tex ) 
{
	local float OrgX, OrgY, ClipX, ClipY;
	
	local bool bOldNoSmooth;
	
	// Metallicafan212:	Disable no smooth
	bOldNoSmooth = C.bNoSmooth;
	C.bNoSmooth = false;

	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;

	C.SetOrigin(OrgX + ClippingRegion.X * Root.GUIScale, OrgY + ClippingRegion.Y * Root.GUIScale);
	C.SetClip(Root.RealWidth, Root.RealHeight);//ClippingRegion.W * Root.GUIScale, ClippingRegion.H * Root.GUIScale);

	C.SetPos((X - ClippingRegion.X) * Root.GUIScale, (Y - ClippingRegion.Y) * Root.GUIScale);
	
	if(bStretchTex)
	{
		C.DrawTileClipped(Tex, WinWidth * Root.GUIScale, WinHeight * Root.GUIScale, tX, tY, tW, tH);
	}
	else
	{
		C.DrawTileClipped( Tex, W * Root.GUIScale * Class'M212HScale'.Static.UWindowGetHeightScale(Root), H * Root.GUIScale * Class'M212HScale'.Static.UWindowGetHeightScale(Root), tX, tY, tW, tH);
	}
	
	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
	
	C.bNoSmooth = bOldNoSmooth;
}

function ResizeControl(float X, float Y, float W, float H)
{
	// Metallicafan212: Resize EVERYTHING
	
}

function Resized()
{
	local float HScale;
	
	Super.Resized();
	
	HScale = Class'M212HScale'.Static.UWindowGetHeightScale(Root);
	
	// Metallicafan212:	Scale our wanted values
	WinTop		= (WY * HScale) + YOffset;
	WinWidth	= WW * HScale;
	WinHeight	= WH * HScale;
	// Omega: Align our button based on its alignment type
	WinLeft		= AlignButton(WX + XOffset);
	
	//RegionScale = GetHeightScale();

	// Metallicafan212:	Scale the region
	UpRegion.W			= WUpRegion.W * HScale;
	UpRegion.H			= WUpRegion.H * HScale;
	UpRegion.Y 			= WUpRegion.Y * HScale;
	
	DownRegion.W		= WDownRegion.W * HScale;
	DownRegion.H		= WDownRegion.H * HScale;
	DownRegion.Y 		= WDownRegion.Y * HScale;
	
	DisabledRegion.W	= WDisabledRegion.W * HScale;
	DisabledRegion.H	= WDisabledRegion.H * HScale;
	DisabledRegion.Y 	= WDisabledRegion.Y * HScale;
	
	OverRegion.W		= WOverRegion.W * HScale;
	OverRegion.H		= WOverRegion.H * HScale;
	OverRegion.Y 		= WOverRegion.Y * HScale;
}

function Created()
{
	Super.Created();
	
	// Metallicafan212:	Save the real X and Y
	WX = WinLeft;
	WY = WinTop;
	WW = WinWidth;
	WH = WinHeight;
	
	WUpRegion 			= UpRegion;
	WDownRegion			= DownRegion;
	WDisabledRegion		= DisabledRegion;
	WOverRegion			= OverRegion;
	
	// Metallicafan212:	Now scale them
	Resized();
}