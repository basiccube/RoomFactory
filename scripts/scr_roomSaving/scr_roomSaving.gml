#macro ROOM_VERSION 1
#macro ROOM_EXTENSION ".rfrm"
#macro ROOM_EXTENSION_CYOP ".json"
#macro ROOM_FILTER "Room Factory room (*.rfrm)|*.rfrm"
#macro ROOM_FILTER_CYOP "CYOP room (*.json)|*.json"
global.roomPath = undefined

///@param {String} path
function save_room(path = undefined)
{
	if (is_undefined(path) || path == "")
	{
		var filter = config_get_file_filter()
		path = get_save_filename_ext(filter[0],
									concat("room", filter[1]),
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

function save_room_rf()
{
	var rm = {}
	
	rm.game = global.config.name
	rm.version = ++obj_roomManager.version
	rm.rf_roomversion = ROOM_VERSION
	rm.rf_version = GM_version
	
	rm.roomInfo = obj_roomManager.roomInfo
	
	var layers = []
	for (var i = 0, n = array_length(global.config[$ "layers"]); i < n; i++)
	{
		var layinfo = global.config[$ "layers"][i]
		if !layer_exists(layinfo.name)
			continue;
		
		var lay = {
			name : layinfo.name,
			depth : layinfo.depth,
			instances : []
		}
		
		var layID = layer_get_id(layinfo.name)
		var elements = layer_get_all_elements(layID)
		for (var j = 0, m = array_length(elements); j < m; j++)
		{
			var element = elements[j]
			switch layer_get_element_type(element)
			{
				case layerelementtype_instance:
					var inst = layer_instance_get_instance(element)
					if (inst.object_index != obj_roomObject)
						break
					
					var instdata = {
						id : inst.objectID,
						x : inst.x,
						y : inst.y,
						xscale : inst.image_xscale,
						yscale : inst.image_yscale,
						variables : inst.variables
					}
					
					array_push(lay.instances, instdata)
					break
					
				default:
					print("Unsupported layer element : ", layer_get_element_type(element))
			}
		}
		
		array_push(layers, lay)
	}
	rm.layers = layers
	
	return rm;
}

function save_room_cyop()
{
	var rm = {}
	
	rm.editorVersion = 6
	rm.isNoiseUpdate = true
	
	rm.properties = {
		roomX : obj_roomManager.cyopRoomInfo.offsetX,
		roomY : obj_roomManager.cyopRoomInfo.offsetY,
		levelWidth : obj_roomManager.roomInfo.width,
		levelHeight : obj_roomManager.roomInfo.height
	}
	
	rm.instances = []
	for (var i = 0, n = instance_number(obj_roomObject); i < n; i++)
	{
		var inst = instance_find(obj_roomObject, i)
		
		var instdata = {
			deleted : false,
			object : inst.objectID,
			layer : abs(inst.depth),
			variables : {}
		}
		
		with (instdata.variables)
		{
			x = inst.x
			y = inst.y
			
			image_xscale = inst.image_xscale
			image_yscale = inst.image_yscale
			
			if (image_xscale < 0)
			{
				flipX = true
				image_xscale *= -1
			}
			if (image_yscale < 0)
			{
				flipY = true
				image_yscale *= -1
			}
		}
		
		for (var j = 0, m = array_length(inst.variables); j < m; j++)
		{
			var v = inst.variables[j]
			struct_set(instdata.variables, v[0], v[1])
		}
		
		array_push(rm.instances, instdata)
	}
	
	return rm;
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
	if (filename_ext(path) != filter[1])
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

function load_room_rf(json)
{
	var errorstr = "Failed to load room."
	
	if !struct_exists(json, "rf_roomversion")
	{
		error_message(errorstr, "No room format version was found. This file may not be a valid room.")
		print("Invalid room, no room format version found")
		return false;
	}
	
	if (json.rf_roomversion != ROOM_VERSION)
	{
		var str = $"Incorrect room version : expected {ROOM_VERSION}, got {json.rf_roomversion}"
		error_message(errorstr, str)
		
		print(str)
		return false;
	}
	
	if (json.game != global.config.name)
	{
		var str = $"Incorrect game configuration loaded : expected {json.game} for this room, got {global.config.name}"
		error_message(errorstr, str)
		
		print(str)
		return false;
	}
	
	obj_roomManager.roomInfo = json.roomInfo
	obj_roomManager.version = json.version
	
	for (var i = 0, n = array_length(json.layers); i < n; i++)
	{
		var lay = json.layers[i]
		if !layer_exists(lay.name)
			layer_create(lay.depth, lay.name)
			
		var layID = layer_get_id(lay.name)
		for (var j = 0, m = array_length(lay.instances); j < m; j++)
		{
			var inst = lay.instances[j]
			var objdata = config_get_objectdata(inst.id, lay.name)
			if is_undefined(objdata)
				continue;
			
			with (create_room_object(inst.x, inst.y, layID, objdata))
			{
				variables = variable_clone(inst.variables)
				image_xscale = inst.xscale
				image_yscale = inst.yscale
			}
		}
	}
	
	return true;
}

global.cyopIgnoredVariables = ["x", "y", "image_xscale", "image_yscale"]

function load_room_cyop(json)
{
	var errorstr = "Failed to load room."
	
	if !struct_exists(json, "editorVersion")
	{
		error_message(errorstr, "No editor version was found. This file may not be a valid room.")
		print("Invalid room, no editor version found")
		return false;
	}
	
	obj_roomManager.cyopRoomInfo.offsetX = json.properties.roomX
	obj_roomManager.cyopRoomInfo.offsetY = json.properties.roomY
	obj_roomManager.roomInfo.width = json.properties.levelWidth
	obj_roomManager.roomInfo.height = json.properties.levelHeight
	
	for (var i = 0, n = array_length(json[$ "instances"]); i < n; i++)
	{
		var inst = json[$ "instances"][i]
		if inst.deleted
			continue;
		
		var layName = concat("Instances_", inst.layer)
		if !layer_exists(layName)
			layer_create(-inst.layer, layName)
		
		var layID = layer_get_id(layName)
		var objdata = config_get_objectdata(inst.object, layName)
		if is_undefined(objdata)
			continue;
			
		with (create_room_object(inst.variables.x, inst.variables.y, layID, objdata))
		{
			image_xscale = inst.variables.image_xscale
			image_yscale = inst.variables.image_yscale
			
			var varnames = struct_get_names(inst.variables)
			for (var j = 0, m = array_length(varnames); j < m; j++)
			{
				var name = varnames[j]
				if array_contains(global.cyopIgnoredVariables, name)
					continue;
					
				var value = struct_get(inst.variables, name)
				var type = typeof(value)
				
				array_push(variables, [name, value, type])
				
				if (name == "flipX" && value)
				{
					x += sprite_width
					image_xscale *= -1
				}
				else if (name == "flipY" && value)
				{
					y += sprite_height
					image_yscale *= -1
				}
			}
		}
	}
	
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
	}
	with (obj_roomManager.cyopRoomInfo)
	{
		offsetX = 0
		offsetY = 0
	}
	obj_roomManager.version = 0
	obj_camera.centerCamera()
	
	config_delete_layers()
	config_create_layers()
	
	print("Cleared room")
	update_titlebar()
}