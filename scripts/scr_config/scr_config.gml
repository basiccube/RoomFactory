#macro CONFIG_PATH "configs/"
#macro CONFIG_FILTER "RoomFactory game configuration|*.rfcfg"
#macro CONFIG_VERSION 1

#macro CONFIG_LAYER_INSTANCE "instance"
#macro CONFIG_LAYER_BACKGROUND "background"
#macro CONFIG_LAYER_TILE "tile"
#macro CONFIG_LAYER_ASSET "asset"

global.config = {}
global.configSprites = ds_map_create()

///@param {String} name
function config_load(name)
{
	var path = concat(CONFIG_PATH, name)
	if !file_exists(path)
		return false;
	
	var str = file_text_read_all(path)
	var json = json_parse(str)
	var errstr = "Failed to load config file."
	
	if !struct_exists(json, "rf_configversion")
	{
		error_message(errstr, "No config format version was found.")
		print("Invalid config, no config format version found")
		return false;
	}
	
	if (json.rf_configversion != CONFIG_VERSION)
	{
		var err = $"Invalid config version, expected {CONFIG_VERSION}, got {json.rf_configversion}"
		error_message(errstr, err)
		
		print($"Invalid config version, expected {CONFIG_VERSION}, got {json.rf_configversion}")
		return false;
	}
	
	global.config = json
	print($"Loaded config {json.name} version {json.version}, format version {json.rf_configversion}")
	
	obj_roomManager.roomFormat = ROOMFORMAT_RF
	if struct_exists(json, "roomFormat")
		obj_roomManager.roomFormat = json.roomFormat
	
	print($"Config room format : {obj_roomManager.roomFormat}")
		
	obj_mainUI.currentLayer = config_find_instance_layer().name
	return true;
}

function config_unload()
{
	if !config_loaded()
	{
		print("No config currently loaded!")
		return false;
	}
	
	print($"Unloading config {global.config.name}")
	delete global.config;
	global.config = {}
	
	var key = ds_map_find_first(global.configSprites)
	for (var i = 0, n = ds_map_size(global.configSprites); i < n; i++)
	{
		var val = ds_map_find_value(global.configSprites, key)
		if sprite_exists(val)
			sprite_delete(val)
		
		key = ds_map_find_next(global.configSprites, key)
	}
	ds_map_clear(global.configSprites)
	
	obj_mainUI.currentLayer = undefined
	return true;
}

function config_loaded()
{
	return (struct_names_count(global.config) > 0);
}

///@param {String} name
///@param {Bool} isDisplayName
function config_get_layer(name, isDisplayName = false)
{
	if !config_loaded()
	{
		print("No configuration loaded yet!")
		return undefined;
	}
	
	if !struct_exists(global.config, "layers")
	{
		print("No layers have been defined, current configuration may be invalid!")
		return undefined;
	}
	
	for (var i = 0, n = array_length(global.config[$ "layers"]); i < n; i++)
	{
		var lay = global.config[$ "layers"][i]
		if (!isDisplayName && lay.name != name)
			continue;
		if (isDisplayName && lay.displayName != name)
			continue;
		
		return lay;
	}
	
	print("Can't find specified layer")
	return undefined;
}

function config_get_layers()
{
	var arr = []
	
	if !config_loaded()
	{
		print("No configuration loaded yet!")
		return arr;
	}
	
	if !struct_exists(global.config, "layers")
	{
		print("No layers have been defined, current configuration may be invalid!")
		return arr;
	}
	
	for (var i = 0, n = array_length(global.config[$ "layers"]); i < n; i++)
	{
		var lay = global.config[$ "layers"][i]
		array_push(arr, lay)
	}
	
	return arr;
}

function config_get_current_layer()
{
	return config_get_layer(obj_mainUI.currentLayer);
}

function config_find_instance_layer()
{
	if !config_loaded()
	{
		print("No configuration loaded yet!")
		return undefined;
	}
	
	if !struct_exists(global.config, "layers")
	{
		print("No layers have been defined, current configuration may be invalid!")
		return undefined;
	}
	
	for (var i = 0, n = array_length(global.config[$ "layers"]); i < n; i++)
	{
		var lay = global.config[$ "layers"][i]
		if (lay.type != CONFIG_LAYER_INSTANCE)
			continue;
		
		return lay;
	}
	
	print("Can't find any instance layers defined in the current configuration")
	return undefined;
}

function config_get_objects()
{
	if !config_loaded()
	{
		print("No configuration loaded yet!")
		return undefined;
	}
	
	var lay = config_get_current_layer()
	if (lay.type != CONFIG_LAYER_INSTANCE)
	{
		print("Incorrect current layer type")
		return undefined;
	}
	
	if !struct_exists(lay, "objects")
	{
		print("No objects defined for current layer!")
		return undefined;
	}
	
	return config_get_layer_objects(lay[$ "objects"]);
}

function config_get_layer_objects(objects)
{
	if is_string(objects)
		return global.config[$ objects];
		
	return objects;
}

function config_create_layers()
{
	print("Creating layers")
	
	var arr = config_get_layers()
	for (var i = 0, n = array_length(arr); i < n; i++)
	{
		var lay = arr[i]
		if !layer_exists(lay.name)
			layer_create(lay.depth, lay.name)
	}
}

function config_delete_layers()
{
	print("Deleting all layers")
	
	var arr = config_get_layers()
	for (var i = 0, n = array_length(arr); i < n; i++)
	{
		var lay = arr[i]
		if !layer_exists(lay.name)
			continue;
		
		var layID = layer_get_id(lay.name)
		layer_destroy_instances(layID)
		layer_destroy(layID)
	}
}

///@param {String} name
function config_get_object_category(name)
{
	if !config_loaded()
	{
		print("No configuration loaded yet!")
		return undefined;
	}
	
	var objects = config_get_objects()
	if is_undefined(objects)
	{
		print("Object array is undefined")
		return undefined;
	}
	
	for (var i = 0, n = array_length(objects); i < n; i++)
	{
		var cat = objects[i]
		if (cat.name != name)
			continue;
		
		return cat;
	}
	
	print("Can't find object category ", name)
	return undefined;
}

///@param {String} name
///@param {String} layerName
function config_get_objectdata(name, layname)
{
	var lay = config_get_layer(layname)
	if is_undefined(lay)
		return undefined;
	
	if (lay.type != CONFIG_LAYER_INSTANCE)
	{
		print("Incorrect layer type")
		return undefined;
	}
	
	var objects = config_get_layer_objects(lay.objects)
	for (var i = 0, n = array_length(objects); i < n; i++)
	{
		var cat = objects[i]
		for (var j = 0, m = array_length(cat.objects); j < m; j++)
		{
			var obj = cat.objects[j]
			if (obj.id != name)
				continue;
			
			return obj;
		}
	}
	
	print($"No object named {name} was found in the current configuration")
	return undefined;
}

///@param {Struct, String} object
function config_get_object_sprite(object)
{
	if is_string(object)
	{
		var spr = ds_map_find_value(global.configSprites, object)
		if (spr != undefined)
			return spr;
		
		return undefined;
	}
	
	var spr = ds_map_find_value(global.configSprites, object[$ "id"])
	if (spr != undefined)
		return spr;
	
	if !struct_exists(object, "sprite")
	{
		print("Can't get object sprite : No sprite base64 string present")
		print("Using generated sprite instead...")
		
		var gspr = create_placeholder_sprite(global.config.roomDefaults.gridSize)
		ds_map_set(global.configSprites, object[$ "id"], gspr)
		
		return gspr;
	}
	
	var offX = 0
	var offY = 0
	if struct_exists(object, "spriteX")
		offX = object[$ "spriteX"]
	if struct_exists(object, "spriteY")
		offY = object[$ "spriteY"]
	
	print("Adding sprite for ", object[$ "id"])
	var s = sprite_add(object[$ "sprite"], 1, false, false, offX, offY)
	
	if struct_exists(object, "spriteBBox")
	{
		var bbox = object[$ "spriteBBox"]
		sprite_set_bbox_mode(s, bboxmode_manual)
		sprite_set_bbox(s, bbox[0], bbox[1], bbox[2], bbox[3])
	}
	
	ds_map_set(global.configSprites, object[$ "id"], s)
	return s;
}

function config_get_file_filter()
{
	static create_filter_struct = function(rm, rmext, lvl, lvlext)
	{
		return {
			room : rm,
			room_ext : rmext,
	
			level : lvl,
			level_ext : lvlext,
	
			combined : rm + "|" + lvl
		};
	}
	
	switch obj_roomManager.roomFormat
	{
		case ROOMFORMAT_RF:
			return create_filter_struct(ROOM_FILTER, ROOM_EXTENSION, LEVEL_FILTER, LEVEL_EXTENSION);
		case ROOMFORMAT_CYOP:
			return create_filter_struct(ROOM_FILTER_CYOP, ROOM_EXTENSION_CYOP, LEVEL_FILTER_CYOP, LEVEL_EXTENSION_CYOP);
	}
}

function config_is_custom_music(musID)
{
	for (var i = 0, n = array_length(global.config.music); i < n; i++)
	{
		var mus = global.config.music[i]
		for (var j = 0, m = array_length(mus.list); j < m; j++)
		{
			var item = mus.list[j]
			if (item.name == musID)
				return false;
		}
	}
	
	return true;
}

function config_get_music_title(musID)
{
	for (var i = 0, n = array_length(global.config.music); i < n; i++)
	{
		var mus = global.config.music[i]
		for (var j = 0, m = array_length(mus.list); j < m; j++)
		{
			var item = mus.list[j]
			if (item.name == musID)
				return item.displayName;
		}
	}
	
	return "";
}

function config_get_object_variables(data)
{
	var arr = []
	
	if struct_exists(data, "variables")
	{
		arr = variable_clone(data.variables)
		for (var i = 0, n = array_length(arr); i < n; i++)
		{
			var v = arr[i]
			if !is_string(v)
				continue;
			if !struct_exists(global.config, v)
				continue;
				
			var nv = variable_clone(global.config[$ v])
			array_delete(arr, i, 1)
				
			i--
			n--
				
			var arrc = array_concat(arr, nv)
			arr = arrc
		}
	}
		
	// check if this object is in the base variable blacklist first
	var inBlacklist = false
	if struct_exists(global.config, "baseVariableBlacklist")
	{
		if array_contains(global.config[$ "baseVariableBlacklist"], data.id)
			inBlacklist = true
	}
			
	// base variables that all objects not in the blacklist will have
	if (!inBlacklist && struct_exists(global.config, "baseVariables"))
	{
		var basearr = variable_clone(global.config[$ "baseVariables"])
		var arrc = array_concat(arr, basearr)
		arr = arrc
	}
	
	return arr;
}

///@param {Real} x
///@param {Real} y
///@param {String, ID.Layer} layer
///@param {Struct} objectData
function create_room_object(ox, oy, olayer, odata)
{
	var oid = undefined
	with (instance_create_layer(ox, oy, olayer, obj_roomObject))
	{
		oid = id
		objectID = odata.id
		variables = config_get_object_variables(odata)
		
		if struct_exists(odata, "allowResize")
			canResize = odata.allowResize
		
		sprite_index = config_get_object_sprite(odata)
	}
	
	return oid;
}