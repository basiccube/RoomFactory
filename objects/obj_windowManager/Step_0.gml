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