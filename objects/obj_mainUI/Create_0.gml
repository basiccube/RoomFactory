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
ImGui.AddFontFromFile("fonts\\OpenSans-Bold.ttf", 16)

showImGuiAboutWindow = false
showAboutWindow = false
showDemoWindow = false

gridSize = 16
gridMaxSize = 32
gridMinSize = 4
gridIncrement = 4

selectedObject = undefined
draggingObject = false
dragX = 0
dragY = 0

resizingObject = false
resizeDir = resizeType.right
resizeInitialWidth = 0
resizeInitialHeight = 0
resizeSavedPos = [0, 0]
resizeSavedScale = [1, 1]
resizeSavedBBox = [0, 0, 0, 0]

currentLayer = undefined
update_titlebar()

var p = get_open_filename(CONFIG_FILTER, "")
if (p != "")
	config_load(p)
else
	game_end(0)