#macro ROOMFACTORY_SETTINGS_FILE "RoomFactory.json"

window_set_min_width(680)
window_set_min_height(580)

// read settings
if file_exists("RoomFactory.json")
{
	var config = json_parse(file_text_read_all(ROOMFACTORY_SETTINGS_FILE))
	window_set_rectangle(config.windowX, config.windowY, config.windowWidth, config.windowHeight)
	event_perform(ev_step, ev_step_normal)
}

globalvar realmouse_x, realmouse_y;