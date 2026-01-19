// draw grid
var gsize = obj_mainUI.gridSize
var gcol = c_gray
for (var i = 0; i < roomInfo.width; i += gsize)
	draw_line_color(i, 0, i, roomInfo.height, gcol, gcol)
for (var i = 0; i < roomInfo.height; i += gsize)
	draw_line_color(0, i, roomInfo.width, i, gcol, gcol)

// draw border
draw_rectangle_color(0, 0, roomInfo.width, roomInfo.height, c_white, c_white, c_white, c_white, true)