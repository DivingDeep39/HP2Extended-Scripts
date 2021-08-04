// Metallicafan212:	Scalable Combo list
class HGameComboList based on UWindowComboList;

var float WX, WY, WW, WH;
var float WVBorder;

//var Region		WUpRegion,  WDownRegion,  WDisabledRegion,  WOverRegion;


function float GetWidthScale()
{
	return (3.0 / 4.0) / (Root.RealHeight / Root.RealWidth);
}

function SetSelected(float X, float Y)
{
	local UWindowComboListItem NewSelected, Item;
	local int i, Count;
	
	// Metallicafan212:	Height scaling
	local float HScale;
	
	HScale = class'M212HScale'.Static.UWindowGetHeightScale(Root);

	Count = 0;
	for( Item = UWindowComboListItem(Items.Next);Item != None; Item = UWindowComboListItem(Item.Next) )
		Count++;

	i = (Y - (VBorder * HScale)) / ((ItemHeight * HScale) + (VertSB.Pos * HScale));

	if(i < 0)
		i = 0;

	if(i >= VertSB.Pos + Min(Count, MaxVisible))
		i = VertSB.Pos + Min(Count, MaxVisible) - 1;

	NewSelected = UWindowComboListItem(Items.FindEntry(i));

	if(NewSelected != Selected)
	{
		if(NewSelected == None) 
			Selected = None;
		else
			Selected = NewSelected;
	}	
}

function ResolutionChanged(float W, float H)
{
	Super.ResolutionChanged(W, H);
	
	// Metallicafan212:	Say we were resized
	Resized();
}

function AddItem(string Value, optional string Value2, optional int SortWeight)
{
	local UWindowComboListItem I;
	
	I = UWindowComboListItem(Items.Append(class'UWindowComboListItem'));
	I.Value = Value;
	I.Value2 = Value2;
	I.SortWeight = SortWeight;
	
	//log("Values are " $ Value $ " " $ Value2);
}

function Paint(Canvas C, float X, float Y)
{
	local int Count;
	local UWindowComboListItem I;

	DrawMenuBackground(C);
	
	Count = 0;

	for( I = UWindowComboListItem(Items.Next);I != None; I = UWindowComboListItem(I.Next) )
	{
		if(VertSB.bWindowVisible)
		{
			if(Count >= VertSB.Pos)
				DrawItem(C, I, HBorder, (VBorder + (ItemHeight * (Count - VertSB.Pos))), WinWidth - (2 * HBorder) - VertSB.WinWidth, ItemHeight);
		}
		else
			DrawItem(C, I, HBorder * Class'M212HScale'.Static.UWindowGetHeightScale(Root), (VBorder + (ItemHeight * Count)) * Class'M212HScale'.Static.UWindowGetHeightScale(Root), WinWidth - (2 * HBorder), ItemHeight);
		Count++;
	}
}

function ClipText(Canvas C, float X, float Y, coerce string S, optional bool bCheckHotkey)
{
	local float OrgX, OrgY, ClipX, ClipY;

	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;

	C.SetOrigin(OrgX + ClippingRegion.X*Root.GUIScale, OrgY + ClippingRegion.Y * Root.HGUIScale);//Root.GUIScale);
	
	// Metallicafan212:	I don't want to bother...
	C.SetClip(Root.RealWidth, Root.RealHeight);//ClippingRegion.W*Root.GUIScale, ClippingRegion.H * Root.HGUIScale);//Root.GUIScale);

	C.SetPos((X - ClippingRegion.X) * Root.GUIScale, (Y - ClippingRegion.Y) * Root.HGUIScale);//Root.GUIScale);
	C.DrawTextClipped(S, bCheckHotKey);

	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
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
	C.DrawTileClipped( Tex, W * Root.GUIScale * Class'M212HScale'.Static.UWindowGetHeightScale(Root), H * Root.GUIScale * Class'M212HScale'.Static.UWindowGetHeightScale(Root), tX, tY, tW, tH);
	
	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
	
	C.bNoSmooth = bOldNoSmooth;
}

function Resized()
{
	local float HScale;
	
	Super.Resized();
	
	HScale = Class'M212HScale'.Static.UWindowGetHeightScale(Root);
	
	// Metallicafan212:	Scale our wanted values
	WinTop		= WY * HScale;
	WinWidth	= WW * HScale;
	WinHeight	= WH * HScale;
	
	//VBorder		= WVBorder * HScale;
}

function Created()
{
	Super.Created();
	
	// Metallicafan212:	Save the real X and Y
	WX = WinLeft;
	WY = WinTop;
	WW = WinWidth;
	WH = WinHeight;
	
	//WVBorder = VBorder;
	
	// Metallicafan212:	Now scale them
	Resized();
}