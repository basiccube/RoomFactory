#macro UI_MAINFONT "fonts\\OpenSans-Bold.ttf"

enum resizeType
{
	right,
	left,
	top,
	bottom,
}

#macro MOUSE_OVER_UI ImGui.WantMouseCapture()
#macro KEYBOARD_USED_UI ImGui.WantKeyboardCapture()
#macro INPUT_USED_UI MOUSE_OVER_UI || KEYBOARD_USED_UI

ImGui.__Initialize()
ImGui.AddFontFromFile(UI_MAINFONT, 16)

globalvar mainFont;
mainFont = font_add(UI_MAINFONT, 10, false, false, 32, 128)
font_enable_sdf(mainFont, true)

showImGuiAboutWindow = false
showAboutWindow = false
showDemoWindow = false
showConfigPicker = true

errorText = "Error!"
errorText2 = ""
showError = false

windows = {
	objectpicker : true,
	layerlist : true,
	inspector : true,
	gridsize : true,
}

gridSize = 16
gridMaxSize = 32
gridMinSize = 4
gridIncrement = 4

selectedObject = undefined
selectedVariableIndex = 0
draggingObject = false
dragPos = new Vector2(0, 0)

resizingObject = false
resizeDir = resizeType.right
resizeInitialSize = new Vector2(0, 0)
resizeSpriteOffset = new Vector2(0, 0)

resizeSavedPos = new Vector2(0, 0)
resizeSavedOffset = new Vector2(0, 0)
resizeSavedScale = new Scale(1, 1)
resizeSavedBBox = new Vector4(0, 0, 0, 0)

currentLayer = undefined
update_titlebar()
	
selectObject = function(inst)
{
	if (selectedObject == inst)
		exit;
	
	print("Selected object : ", inst)
	selectedObject = inst
}
	
deselectObject = function()
{
	if (selectedObject != undefined)
	{
		print("Deselected object : ", selectedObject)
		if instance_exists(selectedObject)
		{
			if (selectedObject.image_xscale == 0)
				selectedObject.image_xscale = 1
			if (selectedObject.image_yscale == 0)
				selectedObject.image_yscale = 1
		}
		
		selectedObject = undefined
	}
}

releaseDraggedObject = function()
{
	if !draggingObject
		exit;
	
	draggingObject = false
	with (selectedObject)
	{
		image_alpha = 1
		move_snap(other.gridSize, other.gridSize)
	}
}