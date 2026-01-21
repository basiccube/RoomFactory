if (INPUT_USED_UI || obj_camera.mouseDrag)
	exit;

x = mouse_x
y = mouse_y

var gsize = obj_mainUI.gridSize
grid_snap(gsize, gsize)

if mouse_check_button_released(mb_left)
{
	var layinfo = config_get_layer(layerName)
	if !layer_exists(layerName)
		layer_create(layinfo.depth, layerName)
	
	create_room_object(x, y, layerName, objectData)
	instance_destroy()
}