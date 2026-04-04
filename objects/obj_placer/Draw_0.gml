if (INPUT_USED_UI || obj_camera.mouseDrag)
	exit;

var gsize = obj_mainUI.gridSize
draw_rectangle_color(x, y, x + gsize, y + gsize, c_green, c_green, c_green, c_green, true)

switch layerType
{
	case CONFIG_LAYER_INSTANCE: objectDraw(); break;
	case CONFIG_LAYER_ASSET: assetDraw(); break;
}