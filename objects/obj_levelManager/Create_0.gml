#macro LEVEL_EXTENSION ".rflvl"
#macro LEVEL_EXTENSION_CYOP ".ini"

#macro LEVEL_FILTER "Room Factory level (level.rflvl)|level.rflvl"
#macro LEVEL_FILTER_CYOP "CYOP tower (tower.ini)|*.tower.ini"

levelPath = ""
levelInfoPath = ""

roomList = []
musicList = []

info = {}

showManagerWindow = false

resetInfo = function()
{
	info = {
		name : "",
		firstRoom : ""
	}
}

resetInfo()

openLevel = function(path)
{
	if !file_exists(path)
		exit;
		
	if (obj_roomManager.roomFormat == ROOMFORMAT_CYOP)
	{
		error_message("Sorry, but CYOP towers aren't supported right now.")
		exit;
	}
		
	levelPath = filename_path(path)
	levelInfoPath = path
	print("Opening level : ", levelPath)
	
	info = json_parse(file_text_read_all(path))
	
	getRooms()
	getMusic()
}

saveLevel = function()
{
	print("Saving level : ", levelPath)
	
	var str = json_stringify(info, true)
	
	var file = file_text_open_write(levelInfoPath)
	file_text_write_string(file, str)
	file_text_close(file)
}

closeLevel = function()
{
	if (levelPath == "")
		exit;
	
	print("Closing level : ", levelPath)
	
	levelPath = ""
	resetInfo()
	showManagerWindow = false
	
	roomList = []
	musicList = []
}

isOpen = function()
{
	return (levelPath != "");
}

iterateDirectory = function(dir, ext)
{
	if !directory_exists(dir)
		exit;
	
	var arr = []
	
	var file = file_find_first(dir + "/*" + ext, fa_none)
	while (file != "")
	{
		array_push(arr, filename_name(file))
		file = file_find_next()
	}
	file_find_close()
	
	return arr;
}

getRooms = function()
{
	roomList = iterateDirectory(levelPath + "rooms", config_get_file_filter().room_ext)
}

getMusic = function()
{
	musicList = iterateDirectory(levelPath + "music", ".ogg")
}