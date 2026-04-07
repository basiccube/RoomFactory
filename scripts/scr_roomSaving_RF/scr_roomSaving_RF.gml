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
			type : layinfo.type
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
					switch inst.object_index
					{
						case obj_layerObject:
							var instdata = {
								id : inst.objectID,
								x : inst.x,
								y : inst.y,
								xscale : inst.image_xscale,
								yscale : inst.image_yscale,
								variables : inst.variables
							}
					
							if !struct_exists(lay, "instances")
								lay.instances = []
							array_push(lay.instances, instdata)
							break
							
						case obj_layerSprite:
							var spritedata = {
								sprite : inst.spriteName,
								x : inst.x,
								y : inst.y,
						
								xscale : inst.image_xscale,
								yscale : inst.image_yscale,
						
								alpha : inst.spriteAlpha,
								angle : inst.image_angle,
						
								index : inst.spriteIndex,
								speed : inst.spriteSpeed
							}
					
							if !struct_exists(lay, "sprites")
								lay.sprites = []
							array_push(lay.sprites, spritedata)
							break
							
						default:
							print($"Unknown object : {inst.object_index}")
					}
					break
					
				default:
					print($"Unsupported layer element : {layer_get_element_type(element)}")
			}
		}
		
		array_push(layers, lay)
	}
	rm.layers = layers
	
	return rm;
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
	
	if (json.rf_roomversion > ROOM_VERSION)
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
		
		// Assume every layer is an instance layer
		// if the type doesn't exist
		if !struct_exists(lay, "type")
			lay.type = CONFIG_LAYER_INSTANCE
			
		var layID = layer_get_id(lay.name)
		switch lay.type
		{
			case CONFIG_LAYER_INSTANCE:
				if !struct_exists(lay, "instances")
					break
			
				for (var j = 0, m = array_length(lay.instances); j < m; j++)
				{
					var inst = lay.instances[j]
					var objdata = config_get_objectdata(inst.id, lay.name)
					if is_undefined(objdata)
					{
						print($"Object not found : {inst.id}")
						objdata = {
							id : inst.id,
							variables : [],
						}
					}
			
					with (create_room_object(inst.x, inst.y, layID, objdata))
					{
						variables = variable_clone(inst.variables)
						image_xscale = inst.xscale
						image_yscale = inst.yscale
					}
				}
				break
				
			case CONFIG_LAYER_ASSET:
				if !struct_exists(lay, "sprites")
					break
					
				for (var j = 0, m = array_length(lay.sprites); j < m; j++)
				{
					var spr = lay.sprites[j]
					var sprData = ConfigAssetSprites.FindSprite(spr.sprite)
					
					with (instance_create_layer(spr.x, spr.y, layID, obj_layerSprite))
					{
						sprite_index = is_undefined(sprData) ? create_placeholder_sprite(global.config.roomDefaults.gridSize) : sprData.GetSprite()
						spriteName = spr.sprite
						
						image_xscale = spr.xscale
						image_yscale = spr.yscale
						
						spriteAlpha = spr.alpha
						image_angle = spr.angle
						
						spriteIndex = spr.index
						spriteSpeed = spr.speed
					}
				}
				break
		}
	}
	
	return true;
}