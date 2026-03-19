#macro ROOMFORMAT_RF "rf"
#macro ROOMFORMAT_CYOP "cyop"

roomInfo = {
	width : 640,
	height : 480,
	title : "Room Title",
	music : ""
}

cyopRoomInfo = {
	offsetX : 0,
	offsetY : 0
}

musicTitle = ""

roomFormat = ROOMFORMAT_RF
version = 0

verifyInfo = function()
{
	if !struct_exists(roomInfo, "width")
		roomInfo.width = global.config.roomDefaults.width
	if !struct_exists(roomInfo, "height")
		roomInfo.height = global.config.roomDefaults.height
	
	roomInfo.width = max(roomInfo.width, global.config.roomDefaults.width)
	roomInfo.height = max(roomInfo.height, global.config.roomDefaults.height)
	
	if (roomFormat == ROOMFORMAT_RF && !struct_exists(roomInfo, "title"))
		roomInfo.title = ""
		
	if !struct_exists(roomInfo, "music")
		roomInfo.music = ""
	musicTitle = config_get_music_title(roomInfo.music)
}