ui_mainmenubar()
ui_objectpicker()
ui_layerlist()
ui_gridsize()
ui_aboutwindow()

if showDemoWindow
	showDemoWindow = ImGui.ShowDemoWindow(showDemoWindow)
if showImGuiAboutWindow
	showImGuiAboutWindow = ImGui.ShowAboutWindow(showImGuiAboutWindow)
	
// grid keyboard controls
if keyboard_check_pressed(vk_add)
	grid_increase()
else if keyboard_check_pressed(vk_subtract)
	grid_decrease()

if INPUT_USED_UI
	exit;
	
// object selection
if mouse_check_button_pressed(mb_left)
{
	if position_meeting(mouse_x, mouse_y, obj_roomObject)
	{
		var inst = instance_position(mouse_x, mouse_y, obj_roomObject)
		if (inst != -4 && selectedObject != inst && layer_get_name(inst.layer) == currentLayer)
		{
			print("Selected object: ", inst)
			selectedObject = inst
		}
	}
	else
	{
		if (selectedObject != undefined)
		{
			print("Deselected object: ", selectedObject)
			selectedObject = undefined
		}
	}
}

// selected object stuff
if (selectedObject != undefined && instance_exists(selectedObject))
{
	var mouseHovering = position_meeting(mouse_x, mouse_y, selectedObject)
	
	// drag
	if (mouseHovering && mouse_check_button(mb_left) && !draggingObject && !resizingObject)
	{
		var dragThreshold = 2
		var startResize = false
		if bbox_on_right_edge(mouse_x, mouse_y, selectedObject)
		{
			if (sign(selectedObject.image_xscale) > 0)
				resizeDir = resizeType.right
			else
				resizeDir = resizeType.left
			startResize = true
		}
		else if bbox_on_left_edge(mouse_x, mouse_y, selectedObject)
		{
			if (sign(selectedObject.image_xscale) > 0)
				resizeDir = resizeType.left
			else
				resizeDir = resizeType.right
			startResize = true
		}
		else if bbox_on_top_edge(mouse_x, mouse_y, selectedObject)
		{
			resizeDir = resizeType.top
			startResize = true
		}
		else if bbox_on_bottom_edge(mouse_x, mouse_y, selectedObject)
		{
			resizeDir = resizeType.bottom
			startResize = true
		}
		else if (abs(window_mouse_get_delta_x()) >= dragThreshold || abs(window_mouse_get_delta_y()) >= dragThreshold)
		{
			dragX = mouse_x - selectedObject.x
			dragY = mouse_y - selectedObject.y
			draggingObject = true
		}
			
		if startResize
		{
			resizeInitialWidth = sprite_get_width(selectedObject.sprite_index)
			resizeInitialHeight = sprite_get_height(selectedObject.sprite_index)
			resizeSavedPos = [selectedObject.x, selectedObject.y]
			resizeSavedScale = [selectedObject.image_xscale, selectedObject.image_yscale]
			resizeSavedBBox = [
				selectedObject.bbox_left,
				selectedObject.bbox_right,
				selectedObject.bbox_top,
				selectedObject.bbox_bottom
			]
			
			resizingObject = true
		}
	}
	
	if draggingObject
	{
		with (selectedObject)
		{
			x = mouse_x - other.dragX
			y = mouse_y - other.dragY
			image_alpha = 0.85
		}
		
		if !mouse_check_button(mb_left)
		{
			draggingObject = false
			with (selectedObject)
			{
				image_alpha = 1
				move_snap(other.gridSize, other.gridSize)
			}
		}
	}
	else if resizingObject
	{
		var px = x
		var py = y
		
		x = mouse_x
		y = mouse_y
		move_snap(gridSize, gridSize)
		
		// janky ass resizing code
		switch resizeDir
		{
			case resizeType.right:
				var initialSize = resizeInitialWidth
				var newSize = x - resizeSavedBBox[0]
				var nx = resizeSavedPos[0]
				
				var scale = newSize / initialSize
				if (sign(scale) == -sign(resizeSavedScale[0]))
				{
					nx += resizeInitialWidth
					scale += sign(scale)
				}
				if (scale == 0)
				{
					nx += resizeInitialWidth
					scale = -1
				}
				
				window_set_cursor(cr_size_we)
				selectedObject.x = nx
				selectedObject.image_xscale = scale
				break
			case resizeType.left:
				var initialSize = resizeInitialWidth
				var newSize = x - resizeSavedBBox[0]
				var scale = newSize / initialSize
				
				var nx = resizeSavedPos[0] + (resizeInitialWidth * scale)
				var nxscale = resizeSavedScale[0] - scale
				if (sign(nxscale) == -sign(resizeSavedScale[0]) || nxscale == 0)
					nxscale -= sign(scale)
				
				window_set_cursor(cr_size_we)
				print(nxscale, ",scale:", scale)
				
				selectedObject.x = nx
				selectedObject.image_xscale = nxscale
				break
			
			case resizeType.top:
				var initialSize = resizeInitialHeight
				var newSize = y - resizeSavedBBox[2]
				var scale = newSize / initialSize
				
				var ny = resizeSavedPos[1] + (resizeInitialHeight * scale)
				var nyscale = resizeSavedScale[1] - scale
				
				window_set_cursor(cr_size_ns)
				if (nyscale > 0)
				{
					selectedObject.y = ny
					selectedObject.image_yscale = nyscale
				}
				break
			case resizeType.bottom:
				var initialSize = resizeInitialHeight
				var newSize = y - resizeSavedBBox[2]
				
				var scale = newSize / initialSize
				if (scale == 0)
					scale = 1
				
				window_set_cursor(cr_size_ns)
				selectedObject.image_yscale = scale
				break
		}
		
		x = px
		y = py
		
		if !mouse_check_button(mb_left)
			resizingObject = false
	}
	else
	{
		// delete
		if keyboard_check_pressed(vk_delete)
		{
			instance_destroy(selectedObject)
			selectedObject = undefined
		}
	}
}