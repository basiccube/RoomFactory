#macro ROOMFACTORY_SETTINGS_FILE "RoomFactory.json"

// read settings
if file_exists("RoomFactory.json")
{
	var config = json_parse(file_text_read_all(ROOMFACTORY_SETTINGS_FILE))
	window_set_rectangle(config.windowX, config.windowY, config.windowWidth, config.windowHeight)
	with (obj_windowManager)
		event_perform(ev_step, ev_step_normal)
	
	global.recents = config.recents
}