#macro ROOM_VERSION 1
#macro ROOM_FILTER "Room Factory room|*.rfrm"
global.roomPath = undefined

///@param {String} path
function save_room(path = undefined)
{
	if (is_undefined(path) || path == "")
	{
		path = get_save_filename_ext(ROOM_FILTER,
									"room.rfrm",
									working_directory,
									"Save Room")
	}
	
	global.roomPath = path
	print("Saving room to ", path)
	
	var rm = {}
	
	rm.version = ROOM_VERSION
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
						yscale : inst.image_yscale
					}
					
					array_push(lay.instances, instdata)
					break
					
				default:
					print("Unsupported layer element: ", layer_get_element_type(element))
			}
		}
		
		array_push(layers, lay)
	}
	rm.layers = layers
	
	var file = file_text_open_write(path)
	file_text_write_string(file, json_stringify(rm, true))
	file_text_close(file)
	
	print("Finished saving room")
	update_titlebar()
}

///@param {String} path
function load_room(path)
{
	if !file_exists(path)
	{
		print("File doesn't exist: ", path)
		return false;
	}
	
	clear_room()
	global.roomPath = path
	print("Loading room from file ", path)
	
	var str = file_text_read_all(path)
	var json = json_parse(str)
	
	if (json.version != ROOM_VERSION)
	{
		print("Incorrect room version: expected", ROOM_VERSION, ", got ", json.version)
		return false;
	}
	
	obj_roomManager.roomInfo = json.roomInfo
	
	for (var i = 0, n = array_length(json.layers); i < n; i++)
	{
		var lay = json.layers[i]
		if !layer_exists(lay.name)
			layer_create(lay.depth, lay.name)
			
		var layID = layer_get_id(lay.name)
		for (var j = 0, m = array_length(lay.instances); j < m; j++)
		{
			var inst = lay.instances[j]
			with (instance_create_layer(inst.x, inst.y, layID, obj_roomObject))
			{
				objectID = inst.id
				
				sprite_index = config_get_object_sprite(objectID)
				if is_undefined(sprite_index)
				{
					var objdata = config_get_objectdata(objectID, lay.name)
					sprite_index = config_get_objectdata_sprite(objdata)
				}
				
				image_xscale = inst.xscale
				image_yscale = inst.yscale
			}
		}
	}
	
	print("Room loaded")
	update_titlebar()
}

function clear_room()
{
	global.roomPath = undefined
	
	with (obj_roomManager.roomInfo)
	{
		width = global.config.roomDefaults.width
		height = global.config.roomDefaults.height
	}
	
	for (var i = 0, n = array_length(global.config[$ "layers"]); i < n; i++)
	{
		var layinfo = global.config[$ "layers"][i]
		if !layer_exists(layinfo.name)
			continue;
			
		var lay = layer_get_id(layinfo.name)
		layer_destroy_instances(lay)
		layer_destroy(lay)
	}
	
	print("Cleared room")
	update_titlebar()
}