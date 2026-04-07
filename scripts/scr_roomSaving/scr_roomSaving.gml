#macro ROOM_VERSION 2

#macro ROOM_EXTENSION ".rfrm"
#macro ROOM_EXTENSION_CYOP ".json"

#macro ROOM_FILTER "Room Factory room (*.rfrm)|*.rfrm"
#macro ROOM_FILTER_CYOP "CYOP room (*.json)|*.json"

#macro ROOM_IS_OPEN (!is_undefined(global.roomPath) && global.roomPath != "")

global.roomPath = undefined

///@param {String} path
function save_room(path = undefined)
{
	if (is_undefined(path) || path == "")
	{
		var filter = config_get_file_filter()
		path = get_save_filename_ext(filter.room,
									$"room{filter.room_ext}",
									working_directory,
									"Save Room")
	}
	
	if (path == "")
		return false;
	
	global.roomPath = path
	print("Saving room to ", path)
	
	var savefunc = save_room_rf
	if (obj_roomManager.roomFormat == ROOMFORMAT_CYOP)
		savefunc = save_room_cyop
	
	var rm = savefunc()
	var file = file_text_open_write(path)
	file_text_write_string(file, json_stringify(rm, true))
	file_text_close(file)
	
	print("Finished saving room")
	update_titlebar()
	
	return true;
}

///@param {String} path
function load_room(path)
{
	if !file_exists(path)
	{
		error_message("File doesn't exist: " + path)
		print("File doesn't exist : ", path)
		return false;
	}
	
	var filter = config_get_file_filter()
	if (filename_ext(path) != filter.room_ext)
	{
		var errstr = "Incorrect room format for current game configuration"
		error_message(errstr)
		
		print(errstr)
		return false;
	}
	
	clear_room()
	print("Loading room from file ", path)
	
	var str = file_text_read_all(path)
	var json = json_parse(str)
	
	var loadfunc = load_room_rf
	if (obj_roomManager.roomFormat == ROOMFORMAT_CYOP)
		loadfunc = load_room_cyop
	
	if !loadfunc(json)
	{
		print("Failed to load room : ", path)
		return false;
	}
	
	print("Room loaded")
	global.roomPath = path
	obj_roomManager.verifyInfo()
	update_titlebar()
	
	return true;
}

function clear_room()
{
	global.roomPath = undefined
	obj_mainUI.deselectObject()
	
	obj_mainUI.gridSize = 16
	if struct_exists(global.config.roomDefaults, "gridSize")
		obj_mainUI.gridSize = global.config.roomDefaults.gridSize
	
	with (obj_roomManager.roomInfo)
	{
		width = global.config.roomDefaults.width
		height = global.config.roomDefaults.height
		title = "Room Title"
		music = ""
	}
	with (obj_roomManager.cyopRoomInfo)
	{
		offsetX = 0
		offsetY = 0
	}
	
	obj_roomManager.musicTitle = "None"
	obj_roomManager.customMusic = false
	
	obj_roomManager.version = 0
	obj_camera.centerCamera()
	
	config_delete_layers()
	config_create_layers()
	
	obj_mainUI.setCurrentLayer(obj_mainUI.currentLayer)
	
	print("Cleared room")
	update_titlebar()
}