updateCamera()
if INPUT_USED_UI
	exit;

var cx = camera_get_view_x(cam)
var cy = camera_get_view_y(cam)

if (keyboard_check_pressed(vk_space) && !mouseDrag)
{
	window_mouse_set_locked(true)
	mouseDrag = true
	
	mouseDragX = window_mouse_get_delta_x()
	mouseDragY = window_mouse_get_delta_y()
}

if mouseDrag
{
	cx -= mouseDragX
	cy -= mouseDragY
	
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
	zoom -= 0.25
else if (keyboard_check_pressed(vk_pagedown) || mouse_wheel_down())
	zoom += 0.25
zoom = clamp(zoom, 0.25, 2)

if keyboard_check_pressed(ord("C"))
	centerCamera()