if (INPUT_USED_UI || obj_camera.mouseDrag)
	exit;

x = mouse_x
y = mouse_y

if obj_mainUI.snapToGrid
{
	var gsize = obj_mainUI.gridSize
	grid_snap(gsize, gsize)
}

if mouse_check_button_released(mb_left)
{
	switch layerType
	{
		case CONFIG_LAYER_INSTANCE: objectPlace(); break;
		case CONFIG_LAYER_ASSET: assetPlace(); break;
	}
	instance_destroy()
}
else if mouse_check_button_released(mb_right)
	instance_destroy()