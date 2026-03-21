updateCamera()
if obj_mainUI.showConfigPicker
	exit;
if (obj_levelManager.isOpen() && !ROOM_IS_OPEN)
	exit;

if INPUT_USED_UI
{
	if mouseDrag
	{
		mouseDrag = false
		window_mouse_set_locked(false)
	}
	exit;
}

var cx = camera_get_view_x(cam)
var cy = camera_get_view_y(cam)

if (keyboard_check_pressed(vk_space) && !mouseDrag)
{
	window_mouse_set_locked(true)
	mouseDrag = true
	
	mouseDragPos.x = window_mouse_get_delta_x()
	mouseDragPos.y = window_mouse_get_delta_y()
}

if mouseDrag
{
	cx -= mouseDragPos.x
	cy -= mouseDragPos.y
	
	if !keyboard_check(vk_space)
	{
		mouseDrag = false
		window_mouse_set_locked(false)
	}
}

var hMove = (-keyboard_check(vk_left) + keyboard_check(vk_right))
var vMove = (-keyboard_check(vk_up) + keyboard_check(vk_down))

var cspd = 5
if keyboard_check(vk_lshift)
	cspd = 10

if (hMove != 0)
	cx += cspd * hMove
if (vMove != 0)
	cy += cspd * vMove

camera_set_view_pos(cam, cx, cy)

if (keyboard_check_pressed(vk_pageup) || mouse_wheel_up())
{
	zoom -= zoomIncrement
	if (zoom >= zoomMin)
	{
		cameraLerp(mouse_x, mouse_y, 0.5)
		updateCamera()
	}
}
else if (keyboard_check_pressed(vk_pagedown) || mouse_wheel_down())
{
	zoom += zoomIncrement
	if (zoom <= zoomMax)
	{
		reverseCameraLerp(mouse_x, mouse_y, 0.5)
		updateCamera()
	}
}
zoom = clamp(zoom, zoomMin, zoomMax)

if keyboard_check_pressed(ord("C"))
	centerCamera()