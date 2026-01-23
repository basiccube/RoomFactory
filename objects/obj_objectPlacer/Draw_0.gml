if (INPUT_USED_UI || obj_camera.mouseDrag)
	exit;

var gsize = obj_mainUI.gridSize
draw_rectangle_color(x, y, x + gsize, y + gsize, c_green, c_green, c_green, c_green, true)

var spr = config_get_object_sprite(objectData)
if (spr != undefined)
	draw_sprite_ext(spr, 0, mouse_x, mouse_y, 1, 1, 0, c_white, 0.5)