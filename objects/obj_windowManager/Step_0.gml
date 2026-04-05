var ww = window_get_width()
var wh = window_get_height()
if (ww <= 0 || wh <= 0)
	exit;

if ((room_width != ww || room_height != wh) && window_has_focus())
{
	surface_resize(application_surface, ww, wh)
	display_set_gui_size(ww, wh)
	
	room_width = ww
	room_height = wh
}

// Hooks for saving the window's maximized state
if window_command_check(window_command_maximize)
{
	settings.windowMaximized = true
	window_command_run(window_command_maximize)
}
if window_command_check(window_command_restore)
{
	settings.windowMaximized = false
	window_command_run(window_command_restore)
}