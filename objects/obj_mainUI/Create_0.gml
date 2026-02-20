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
#macro INPUT_USED_UI (MOUSE_OVER_UI || KEYBOARD_USED_UI)

ImGui.__Initialize()
ImGui.AddFontFromFile(UI_MAINFONT, 16)

globalvar mainFont;
mainFont = font_add(UI_MAINFONT, 10, false, false, 32, 128)
font_enable_sdf(mainFont, true)

settings_load()

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

selectionArray = []
selectedVariableIndex = 0
draggingObject = false
dragPosArray = []

multiSelect = false
multiSelectStartPos = new Vector2(0, 0)

resizingObject = false
resizeDir = resizeType.right
resizeInitialSize = new Vector2(0, 0)
resizeSpriteOffset = new Vector2(0, 0)

resizeSavedPos = new Vector2(0, 0)
resizeSavedOffset = new Vector2(0, 0)
resizeSavedScale = new Scale(1, 1)
resizeSavedBBox = new Vector4(0, 0, 0, 0)

currentLayer = undefined
lastObject = undefined
update_titlebar()
	
selectObject = function(inst)
{
	if (array_length(selectionArray) > 0 && selectionArray[0] == inst)
		exit;
	
	print("Selected object : ", inst)
	selectionArray = [inst]
	multiSelect = false
}
	
deselectObject = function()
{
	if (array_length(selectionArray) <= 0)
		exit;
	
	print("Deselecting objects")
	array_foreach(selectionArray, function(e, i)
	{
		if instance_exists(e)
		{
			if (e.image_xscale == 0)
				e.image_xscale = 1
			if (e.image_yscale == 0)
				e.image_yscale = 1
		}
	})
	
	selectionArray = []
}

releaseDraggedObject = function()
{
	if !draggingObject
		exit;
	
	array_foreach(dragPosArray, function(e, i)
	{
		delete e;
	})
	dragPosArray = []
	
	array_foreach(selectionArray, function(e, i)
	{
		with (e)
		{
			image_alpha = 1
			move_snap(other.gridSize, other.gridSize)
		}
	})
	
	draggingObject = false
}

isMultiSelection = function()
{
	return (array_length(selectionArray) > 1);
}

drawInstanceOutline = function(inst, color)
{
	draw_rectangle_color(
		inst.bbox_left,
		inst.bbox_top,
		inst.bbox_right,
		inst.bbox_bottom,
		color,
		color,
		color,
		color,
		true
	)
}

instanceListCheck = function(inst)
{
	if (inst == -4)
		return false;
	if !instance_exists(inst)
		return false;
	if (layer_get_name(inst.layer) != currentLayer)
		return false;
	
	return true;
}