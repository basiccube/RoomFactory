if showConfigPicker
{
	ui_configpicker()
	exit;
}
if (obj_levelManager.isOpen() && !ROOM_IS_OPEN)
	exit;

ui_mainmenubar()
ui_objectpicker()
ui_layerlist()
ui_inspector()
ui_gridsize()
ui_aboutwindow()
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

if multiSelect
{
	if !mouse_check_button(mb_left)
	{
		selectionArray = []
		
		var num = collision_rectangle_list(
			multiSelectStartPos.x,
			multiSelectStartPos.y,
			mouse_x,
			mouse_y,
			obj_roomObject,
			false,
			true,
			tempMeetingList,
			false
		)
		
		for (var i = 0; i < num; i++)
		{
			var inst = ds_list_find_value(tempMeetingList, i)
			if instanceListCheck(inst)
				array_push(selectionArray, inst)
		}
		ds_list_clear(tempMeetingList)
		
		multiSelect = false
	}
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
{
	multiSelect = false
	exit;
}
	
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
if (mouse_check_button_pressed(mb_left) && !keyboard_check(vk_alt) && !instance_exists(obj_objectPlacer))
{
	if position_meeting(mouse_x, mouse_y, obj_roomObject)
	{
		var deselect = true
		var num = instance_position_list(mouse_x, mouse_y, obj_roomObject, tempMeetingList, false)
		for (var i = 0; i < num; i++)
		{
			var inst = ds_list_find_value(tempMeetingList, i)
			if (inst == -4)
				continue;
			if (layer_get_name(inst.layer) != currentLayer)
				continue;
			
			if (isMultiSelection() && array_contains(selectionArray, inst))
			{
				deselect = false
				continue;
			}
			
			selectObject(inst)
			deselect = false
			break;
		}
		ds_list_clear(tempMeetingList)
		
		if deselect
			deselectObject()
	}
	else
	{
		if (keyboard_check(vk_shift) && !multiSelect)
		{
			multiSelectStartPos.set(mouse_x, mouse_y)
			multiSelect = true
		}
		deselectObject()
	}
}

// selected object stuff
if (array_length(selectionArray) <= 0)
	exit;
	
var selectedObject = selectionArray[0]
if is_undefined(selectionArray[0])
	exit;
if !instance_exists(selectedObject)
	exit;

var mouseHovering = position_meeting(mouse_x, mouse_y, selectedObject)
if (isMultiSelection() && !mouseHovering)
{
	for (var i = 0, n = array_length(selectionArray); i < n; i++)
	{
		var inst = selectionArray[i]
		if (instance_exists(inst) && position_meeting(mouse_x, mouse_y, inst))
		{
			mouseHovering = true
			break;
		}
	}
}

// drag and resize
if (mouseHovering && mouse_check_button(mb_left) && !keyboard_check(vk_alt) && !draggingObject && !resizingObject)
{
	var dragThreshold = 1
	var startResize = false
	var canResize = selectedObject.canResize
	if isMultiSelection()
		canResize = false
	
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
		array_foreach(selectionArray, function(e, i)
		{
			var pos = new Vector2(
				mouse_x - e.x, 
				mouse_y - e.y
			)
			
			dragPosArray[i] = pos
		})
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
	array_foreach(selectionArray, function(e, i)
	{
		with (e)
		{
			x = mouse_x - other.dragPosArray[i].x
			y = mouse_y - other.dragPosArray[i].y
			image_alpha = 0.85
		}
	})
	
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
		instance_destroy_array(selectionArray)
		deselectObject()
	}
}