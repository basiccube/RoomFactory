if !config_loaded()
	exit;
if (layer_exists(currentLayer) && !layer_get_visible(currentLayer))
	exit;

if (position_meeting(mouse_x, mouse_y, obj_roomObject) &&
	!instance_exists(obj_placer) &&
	!INPUT_USED_UI &&
	!window_mouse_get_locked() &&
	!draggingObject &&
	!resizingObject &&
	!multiSelect &&
	!obj_camera.mouseDrag)
{
	var num = instance_position_list(mouse_x, mouse_y, obj_roomObject, tempMeetingList, false)
	for (var i = 0; i < num; i++)
	{
		var inst = ds_list_find_value(tempMeetingList, i)
		if instanceListCheck(inst)
		{
			drawInstanceOutline(inst, c_white)
			break;
		}
	}
	ds_list_clear(tempMeetingList)
}

// hold alt visual
if (lastObject != undefined && !INPUT_USED_UI && !window_mouse_get_locked() && keyboard_check(vk_alt))
{
	var px = x
	var py = y
		
	x = mouse_x
	y = mouse_y
	if snapToGrid
		grid_snap(gridSize, gridSize)
	
	var c = c_green
	draw_rectangle_color(x, y, x + gridSize, y + gridSize, c, c, c, c, true)
	
	x = px
	y = py
	
	var spr = config_get_object_sprite(lastObject)
	if (spr != undefined)
		draw_sprite_ext(spr, 0, mouse_x, mouse_y, 1, 1, 0, c_white, 0.5)
}

if isMultiSelection()
{
	for (var i = 0, n = array_length(selectionArray); i < n; i++)
	{
		var inst = selectionArray[i]
		if instance_exists(inst)
			drawInstanceOutline(inst, c_white)
	}
}

if (array_length(selectionArray) > 0 && !isMultiSelection() && !is_undefined(selectionArray[0]))
{
	var selectedObject = selectionArray[0]
	
	drawInstanceOutline(selectedObject, c_teal)
	if INPUT_USED_UI
		exit;
	
	var drawEdges = false
	var drawLeftEdge = false
	var drawRightEdge = false
	var drawTopEdge = false
	var drawBottomEdge = false
	
	if resizingObject
	{
		drawEdges = true
		switch resizeDir
		{
			case resizeType.left:
				drawLeftEdge = true
				window_set_cursor(cr_size_we)
				break
			case resizeType.right:
				drawRightEdge = true
				window_set_cursor(cr_size_we)
				break
			case resizeType.top:
				drawTopEdge = true
				window_set_cursor(cr_size_ns)
				break
			case resizeType.bottom:
				drawBottomEdge = true
				window_set_cursor(cr_size_ns)
				break
		}
	}
	else if draggingObject
		window_set_cursor(cr_size_all)
	else
	{
		// resize visuals
		if (selectedObject.canResize && !keyboard_check(vk_alt) && !window_mouse_get_locked() && position_meeting(mouse_x, mouse_y, selectedObject))
		{
			if bbox_on_left_edge(mouse_x, mouse_y, selectedObject)
			{
				drawEdges = true
				drawLeftEdge = true
				window_set_cursor(cr_size_we)
			}
			else if bbox_on_right_edge(mouse_x, mouse_y, selectedObject)
			{
				drawEdges = true
				drawRightEdge = true
				window_set_cursor(cr_size_we)
			}
			else if bbox_on_top_edge(mouse_x, mouse_y, selectedObject)
			{
				drawEdges = true
				drawTopEdge = true
				window_set_cursor(cr_size_ns)
			}
			else if bbox_on_bottom_edge(mouse_x, mouse_y, selectedObject)
			{
				drawEdges = true
				drawBottomEdge = true
				window_set_cursor(cr_size_ns)
			}
		}
	}
	
	if drawEdges
	{
		var rcol = c_white
		if resizingObject
		{
			rcol = c_red
			
			var prevleft = drawLeftEdge
			var prevright = drawRightEdge
			var prevtop = drawTopEdge
			var prevbottom = drawBottomEdge
			if (selectedObject.image_xscale < 0)
			{
				drawLeftEdge = prevright
				drawRightEdge = prevleft
			}
			if (selectedObject.image_yscale < 0)
			{
				drawTopEdge = prevbottom
				drawBottomEdge = prevtop
			}
		}
		
		var bleft = selectedObject.bbox_left
		var bright = selectedObject.bbox_right
		var btop = selectedObject.bbox_top
		var bbottom = selectedObject.bbox_bottom
		
		if drawLeftEdge
			draw_line_color(bleft, btop, bleft, bbottom, rcol, rcol)
		else if drawRightEdge
			draw_line_color(bright, btop, bright, bbottom, rcol, rcol)
		else if drawTopEdge
			draw_line_color(bleft, btop, bright, btop, rcol, rcol)
		else if drawBottomEdge
			draw_line_color(bleft, bbottom, bright, bbottom, rcol, rcol)
	}
}

if multiSelect
{
	var a = draw_get_alpha()
	var c = c_aqua
	
	draw_set_alpha(0.65)
	draw_rectangle_color(multiSelectStartPos.x, multiSelectStartPos.y, mouse_x, mouse_y, c, c, c, c, true)
	
	draw_set_alpha(0.25)
	draw_rectangle_color(multiSelectStartPos.x, multiSelectStartPos.y, mouse_x, mouse_y, c, c, c, c, false)
	
	draw_set_alpha(a)
	
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
			drawInstanceOutline(inst, c_white)
	}
	ds_list_clear(tempMeetingList)
}