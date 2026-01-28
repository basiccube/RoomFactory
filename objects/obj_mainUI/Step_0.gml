if showConfigPicker
{
	ui_configpicker()
	ui_errormessage()
	exit;
}

ui_mainmenubar()
ui_objectpicker()
ui_layerlist()
ui_inspector()
ui_gridsize()
ui_aboutwindow()
ui_errormessage()
menu_handle_shortcuts()

if showDemoWindow
	showDemoWindow = ImGui.ShowDemoWindow(showDemoWindow)
if showImGuiAboutWindow
	showImGuiAboutWindow = ImGui.ShowAboutWindow(showImGuiAboutWindow)

// grid keyboard controls
if keyboard_check_pressed(vk_add)
	grid_increase()
else if keyboard_check_pressed(vk_subtract)
	grid_decrease()

if !config_loaded()
	exit;

if (layer_exists(currentLayer) && !layer_get_visible(currentLayer))
{
	deselectObject()
	exit;
}

if INPUT_USED_UI
{
	if (!mouse_check_button(mb_left) && (resizingObject || draggingObject))
	{
		window_set_cursor(cr_default)
		resizingObject = false
		if draggingObject
			releaseDraggedObject()
	}
	exit;
}
if window_mouse_get_locked()
	exit;
	
// hold alt to create last picked object
if (lastObject != undefined && keyboard_check(vk_alt))
{
	if mouse_check_button_released(mb_left)
	{
		var px = x
		var py = y
		
		x = mouse_x
		y = mouse_y
		grid_snap(gridSize, gridSize)
		
		create_room_object(x, y, currentLayer, lastObject)
		
		x = px
		y = py
	}
}
	
// object selection
if (mouse_check_button_pressed(mb_left) && !keyboard_check(vk_alt))
{
	if position_meeting(mouse_x, mouse_y, obj_roomObject)
	{
		var deselect = true
		var num = instance_position_list(mouse_x, mouse_y, obj_roomObject, tempMeetingList, false)
		for (var i = 0; i < num; i++)
		{
			var inst = ds_list_find_value(tempMeetingList, i)
			if (inst != -4 && layer_get_name(inst.layer) == currentLayer)
			{
				selectObject(inst)
				deselect = false
				break;
			}
		}
		ds_list_clear(tempMeetingList)
		
		if deselect
			deselectObject()
	}
	else
		deselectObject()
}

// selected object stuff
if (selectedObject != undefined && instance_exists(selectedObject))
{
	var mouseHovering = position_meeting(mouse_x, mouse_y, selectedObject)
	
	// drag and resize
	if (mouseHovering && mouse_check_button(mb_left) && !keyboard_check(vk_alt) && !draggingObject && !resizingObject)
	{
		var dragThreshold = 1
		var startResize = false
		var canResize = selectedObject.canResize
		
		if (canResize && bbox_on_right_edge(mouse_x, mouse_y, selectedObject))
		{
			if (sign(selectedObject.image_xscale) > 0)
				resizeDir = resizeType.right
			else
				resizeDir = resizeType.left
			startResize = true
		}
		else if (canResize && bbox_on_left_edge(mouse_x, mouse_y, selectedObject))
		{
			if (sign(selectedObject.image_xscale) > 0)
				resizeDir = resizeType.left
			else
				resizeDir = resizeType.right
			startResize = true
		}
		else if (canResize && bbox_on_top_edge(mouse_x, mouse_y, selectedObject))
		{
			if (sign(selectedObject.image_yscale) > 0)
				resizeDir = resizeType.top
			else
				resizeDir = resizeType.bottom
			startResize = true
		}
		else if (canResize && bbox_on_bottom_edge(mouse_x, mouse_y, selectedObject))
		{
			if (sign(selectedObject.image_yscale) > 0)
				resizeDir = resizeType.bottom
			else
				resizeDir = resizeType.top
			startResize = true
		}
		else if (abs(window_mouse_get_delta_x()) >= dragThreshold || abs(window_mouse_get_delta_y()) >= dragThreshold)
		{
			dragPos.x = mouse_x - selectedObject.x
			dragPos.y = mouse_y - selectedObject.y
			draggingObject = true
		}
			
		if startResize
		{
			resizeInitialSize.set(sprite_get_width(selectedObject.sprite_index),
								sprite_get_height(selectedObject.sprite_index))
			
			resizeSpriteOffset.set(sprite_get_xoffset(selectedObject.sprite_index),
								sprite_get_yoffset(selectedObject.sprite_index))
			
			resizeSavedPos.set(selectedObject.x, selectedObject.y)
			resizeSavedOffset.set(selectedObject.sprite_xoffset, selectedObject.sprite_yoffset)
			resizeSavedScale.set(selectedObject.image_xscale, selectedObject.image_yscale)
			resizeSavedBBox.set(selectedObject.bbox_left,
								selectedObject.bbox_top,
								selectedObject.bbox_right,
								selectedObject.bbox_bottom)
			
			resizingObject = true
		}
	}
	
	if draggingObject
	{
		with (selectedObject)
		{
			x = mouse_x - other.dragPos.x
			y = mouse_y - other.dragPos.y
			image_alpha = 0.85
		}
		
		if !mouse_check_button(mb_left)
			releaseDraggedObject()
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
				var leftBBox = resizeSavedBBox.x1
				if (resizeSavedScale.x < 0)
					leftBBox = resizeSavedBBox.x2
			
				var initialSize = resizeInitialSize.x
				var newSize = x - leftBBox
				
				var scale = newSize / initialSize
				var nx = resizeSavedPos.x
				if (sign(scale) == -sign(resizeSavedScale.x))
				{
					nx += initialSize * sign(resizeSavedScale.x)
					scale += sign(scale)
				}
				if (scale == 0)
				{
					nx += initialSize * sign(resizeSavedScale.x)
					scale = -1 * sign(resizeSavedScale.x)
				}
				
				if (resizeSavedScale.x != scale)
					nx += resizeSpriteOffset.x * (scale - 1)
				
				selectedObject.x = nx
				selectedObject.image_xscale = scale
				break
			case resizeType.left:
				var leftBBox = resizeSavedBBox.x1
				if (resizeSavedScale.x < 0)
					leftBBox = resizeSavedBBox.x2
			
				var initialSize = resizeInitialSize.x
				var newSize = x - leftBBox
				var scale = newSize / initialSize
				
				var nx = resizeSavedPos.x + (initialSize * scale)
				var nxscale = resizeSavedScale.x - scale
				if (sign(nxscale) == -sign(resizeSavedScale.x) || nxscale == 0)
					nxscale -= sign(scale)
				
				selectedObject.x = nx
				selectedObject.image_xscale = nxscale
				break
			
			case resizeType.top:
				var topBBox = resizeSavedBBox.y1
				if (resizeSavedScale.y < 0)
					topBBox = resizeSavedBBox.y2
			
				var initialSize = resizeInitialSize.y
				var newSize = y - topBBox
				var scale = newSize / initialSize
				
				var ny = resizeSavedPos.y + (initialSize * scale)
				var nyscale = resizeSavedScale.y - scale
				if (sign(nyscale) == -sign(resizeSavedScale.y) || nyscale == 0)
					nyscale -= sign(scale)
				
				selectedObject.y = ny
				selectedObject.image_yscale = nyscale
				break
			case resizeType.bottom:
				var topBBox = resizeSavedBBox.y1
				if (resizeSavedScale.y < 0)
					topBBox = resizeSavedBBox.y2
			
				var initialSize = resizeInitialSize.y
				var newSize = y - topBBox
				var ny = resizeSavedPos.y
				
				var scale = newSize / initialSize
				if (sign(scale) == -sign(resizeSavedScale.y))
				{
					ny += initialSize * sign(resizeSavedScale.y)
					scale += sign(scale)
				}
				if (scale == 0)
				{
					ny += initialSize * sign(resizeSavedScale.y)
					scale = -1 * sign(resizeSavedScale.y)
				}
				
				selectedObject.y = ny
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
			deselectObject()
		}
	}
}