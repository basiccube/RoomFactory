#macro ROOMFACTORY_SETTINGS_FILE "RoomFactory_Settings.json"
#macro MAX_RECENTS 6

global.settings = undefined

function settingsData() constructor
{	
	windowRect = {
		x : 0,
		y : 0,
		w : 0,
		h : 0,
	}
	
	recents = array_create(MAX_RECENTS, undefined)
}

function settings_apply()
{
	if is_undefined(global.settings)
		exit;
		
	window_set_rectangle(
		global.settings.windowRect.x,
		global.settings.windowRect.y,
		global.settings.windowRect.w,
		global.settings.windowRect.h
	)
	with (obj_windowManager)
		event_perform(ev_step, ev_step_normal)
}

function settings_load()
{
	if !file_exists(ROOMFACTORY_SETTINGS_FILE)
	{
		global.settings = new settingsData()
		exit;
	}
	
	// read settings
	global.settings = json_parse(file_text_read_all(ROOMFACTORY_SETTINGS_FILE))
	settings_apply()
}

function settings_save()
{
	with (global.settings.windowRect)
	{
		x = window_get_x()
		y = window_get_y()
		w = window_get_width()
		h = window_get_height()
	}
	
	var json = json_stringify(global.settings, true)
	var file = file_text_open_write(ROOMFACTORY_SETTINGS_FILE)
	file_text_write_string(file, json)
	file_text_close(file)
}

///@param {String} file
function recents_push(file)
{
	if array_contains(global.settings.recents, file)
		exit;
	
	array_insert(global.settings.recents, 0, file)
	array_pop(global.settings.recents)
}