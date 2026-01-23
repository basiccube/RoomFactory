if !config_loaded()
	exit;
if (layer_exists(currentLayer) && !layer_get_visible(currentLayer))
	exit;

if (position_meeting(mouse_x, mouse_y, obj_roomObject) &&
	!instance_exists(obj_objectPlacer) &&
	!(INPUT_USED_UI) &&
	!window_mouse_get_locked() &&
	!draggingObject &&
	!resizingObject &&
	!obj_camera.mouseDrag)
{
	var num = instance_position_list(mouse_x, mouse_y, obj_roomObject, tempMeetingList, false)
	for (var i = 0; i < num; i++)
	{
		var inst = ds_list_find_value(tempMeetingList, i)
		if (inst == -4)
			continue;
		if (layer_get_name(inst.layer) != other.currentLayer)
			continue;
		
		with (inst)
		{
			var c = c_white
			draw_rectangle_color(bbox_left, bbox_top, bbox_right, bbox_bottom, c, c, c, c, true)
		}
		break;
	}
	ds_list_clear(tempMeetingList)
}

if (selectedObject != undefined)
{
	var c = c_teal
	draw_rectangle_color(selectedObject.bbox_left,
						selectedObject.bbox_top,
						selectedObject.bbox_right,
						selectedObject.bbox_bottom,
						c, c, c, c,
						true)
	
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
		if (selectedObject.canResize && !window_mouse_get_locked() && position_meeting(mouse_x, mouse_y, selectedObject))
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