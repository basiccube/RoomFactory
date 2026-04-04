#macro ROOMFACTORY_SETTINGS_FILE "RoomFactory_Settings.json"
#macro MAX_RECENTS 6

enum SettingsTheme
{
	Light,
	Dark
}

globalvar settings;
settings = undefined

function settingsData() constructor
{	
	windowRect = {
		x : 0,
		y : 0,
		w : 0,
		h : 0,
	}
	
	theme = SettingsTheme.Dark
	scale = 1
	recents = array_create(MAX_RECENTS, undefined)
}

function settings_exists(name)
{ return struct_exists(settings, name); }

function settings_apply()
{
	if is_undefined(settings)
		exit;
		
	static defaults = new settingsData()
	static initialApply = true
	
	if !settings_exists("scale")
		settings.scale = defaults.scale
	
	if initialApply
	{
		window_set_rectangle(
			settings.windowRect.x,
			settings.windowRect.y,
			settings.windowRect.w,
			settings.windowRect.h
		)
		
		with (obj_windowManager)
			event_perform(ev_step, ev_step_normal)
			
		ImGui.AddFontFromFileTTF(UI_MAINFONT, UI_FONTSIZE * settings.scale)

		globalvar mainFont;
		mainFont = font_add(UI_MAINFONT, 10 * settings.scale, false, false, 32, 128)
		font_enable_sdf(mainFont, true)
			
		initialApply = false
	}
	
	if !settings_exists("theme")
		settings.theme = defaults.theme
	
	if (settings.theme == SettingsTheme.Light)
		ImGui.StyleColorsLight()
	else
		ImGui.StyleColorsDark()
}

function settings_load()
{
	if !file_exists(ROOMFACTORY_SETTINGS_FILE)
	{
		settings = new settingsData()
		exit;
	}
	
	// read settings
	settings = json_parse(file_text_read_all(ROOMFACTORY_SETTINGS_FILE))
	settings_apply()
}

function settings_save()
{
	with (settings.windowRect)
	{
		x = window_get_x()
		y = window_get_y()
		w = window_get_width()
		h = window_get_height()
	}
	
	var json = json_stringify(settings, true)
	var file = file_text_open_write(ROOMFACTORY_SETTINGS_FILE)
	file_text_write_string(file, json)
	file_text_close(file)
}

///@param {String} file
function recents_push(file)
{
	if array_contains(settings.recents, file)
		exit;
	
	array_insert(settings.recents, 0, file)
	array_pop(settings.recents)
}

function recents_clear()
{ settings.recents = array_create(MAX_RECENTS, undefined); }