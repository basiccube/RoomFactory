if INPUT_USED_UI
	exit;
if obj_camera.mouseDrag
	exit;
if (array_length(selectionArray) <= 0)
	exit;
if isMultiSelection()
	exit;
if is_undefined(selectionArray[0])
	exit;

var selectedObject = selectionArray[0]
var str = ""
if resizingObject
{
	var xscale = selectedObject.image_xscale
	var yscale = selectedObject.image_yscale
	str = $"X: {xscale}, Y: {yscale}"
}
else if draggingObject
{
	var ox = selectedObject.x
	var oy = selectedObject.y
	var px = ox
	var py = oy
		
	with (selectedObject)
	{
		move_snap(other.gridSize, other.gridSize)
		ox = x
		oy = y
			
		x = px
		y = py
	}
	
	str = $"X: {ox}, Y: {oy}"
}
	
draw_mouse_tooltip(0, 16, str)