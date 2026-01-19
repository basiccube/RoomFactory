var config = {
	windowX : window_get_x(),
	windowY : window_get_y(),
	windowWidth : window_get_width(),
	windowHeight : window_get_height(),
}

var json = json_stringify(config, true)
var file = file_text_open_write(ROOMFACTORY_SETTINGS_FILE)
file_text_write_string(file, json)
file_text_close(file)