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
	
	with (instance_create_layer(x, y, layerName, obj_roomObject))
	{
		objectID = other.objectData.id
		sprite_index = config_get_objectdata_sprite(other.objectData)
	}
	instance_destroy()
}