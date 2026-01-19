cameraInit = function()
{
	view_set_camera(0, cam)
	view_set_wport(0, room_width)
	view_set_hport(0, room_height)
	view_set_visible(0, true)
	view_enabled = true
}

updateCamera = function()
{
	view_set_wport(0, room_width * zoom)
	view_set_hport(0, room_height * zoom)
	camera_set_view_size(cam, room_width * zoom, room_height * zoom)
}

centerCamera = function()
{
	if !instance_exists(obj_roomManager)
		exit;
		
	var nx = (obj_roomManager.roomInfo.width / 2) - ((room_width * zoom) / 2)
	var ny = (obj_roomManager.roomInfo.height / 2) - ((room_height * zoom) / 2)
	
	camera_set_view_pos(cam, nx, ny)
}

cam = camera_create_view(0, 0, room_width, room_height)
zoom = 1

cameraInit()
centerCamera()

mouseDrag = false
mouseDragX = 0
mouseDragY = 0