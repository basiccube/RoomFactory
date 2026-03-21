if obj_mainUI.showConfigPicker
	exit;
if (obj_levelManager.isOpen() && !ROOM_IS_OPEN)
	exit;

// draw grid
var gsize = obj_mainUI.gridSize
var gcol = c_gray

var offX = 0
var offY = 0
if (roomFormat == ROOMFORMAT_CYOP)
{
	offX = cyopRoomInfo.offsetX
	offY = cyopRoomInfo.offsetY
}

var offsetPos = get_grid_pos(offX, offY, gsize, gsize)
if (offsetPos[0] < offX)
	offsetPos[0] += gsize
if (offsetPos[1] < offY)
	offsetPos[1] += gsize

for (var i = offsetPos[0]; i < roomInfo.width; i += gsize)
	draw_line_color(i, offY, i, roomInfo.height, gcol, gcol)
for (var i = offsetPos[1]; i < roomInfo.height; i += gsize)
	draw_line_color(offX, i, roomInfo.width, i, gcol, gcol)

// draw border
draw_rectangle_color(offX, offY, roomInfo.width, roomInfo.height, c_white, c_white, c_white, c_white, true)