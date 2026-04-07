function CYOPInstanceData(inst) constructor
{
	deleted = false
	object = inst.objectID
	layer = abs(inst.depth)
	variables = {}
	
	with (variables)
	{
		x = inst.x
		y = inst.y
			
		image_xscale = inst.image_xscale
		image_yscale = inst.image_yscale
			
		if (image_xscale < 0)
		{
			flipX = true
			x += inst.sprite_width
			image_xscale *= -1
		}
		if (image_yscale < 0)
		{
			flipY = true
			y += inst.sprite_height
			image_yscale *= -1
		}
	}
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
		levelHeight : obj_roomManager.roomInfo.height,
		song : obj_roomManager.roomInfo.music
	}
	
	rm.instances = []
	for (var i = 0, n = instance_number(obj_layerObject); i < n; i++)
	{
		var inst = instance_find(obj_layerObject, i)
		var instdata = new CYOPInstanceData(inst)
		
		for (var j = 0, m = array_length(inst.variables); j < m; j++)
		{
			var v = inst.variables[j]
			struct_set(instdata.variables, v[0], v[1])
		}
		
		array_push(rm.instances, instdata)
	}
	
	for (var i = 0, n = instance_number(obj_layerSprite); i < n; i++)
	{
		var inst = instance_find(obj_layerSprite, i)
		var instdata = new CYOPInstanceData(inst)
		
		instdata.object = "obj_sprite"
		with (instdata.variables)
		{
			sprite_index = inst.spriteName
			
			image_alpha = inst.spriteAlpha
			image_angle = inst.image_angle
			
			image_index = inst.spriteIndex
			image_speed = inst.spriteSpeed
		}
		
		array_push(rm.instances, instdata)
	}
	
	return rm;
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
	obj_roomManager.roomInfo.music = json.properties.song
	
	for (var i = 0, n = array_length(json[$ "instances"]); i < n; i++)
	{
		var inst = json[$ "instances"][i]
		if inst.deleted
			continue;
		
		var layName = $"{CYOP_INSTANCE_LAYER_PREFIX}{inst.layer}"
		if !layer_exists(layName)
			layer_create(-inst.layer, layName)
		
		var layID = layer_get_id(layName)
		var objdata = config_get_objectdata(inst.object, layName)
		if is_undefined(objdata)
		{
			print($"Object not found : {inst.object}")
			objdata = {
				id : inst.object,
				variables : [],
			}
		}
			
		with (create_room_object(inst.variables.x, inst.variables.y, layID, objdata))
		{
			if struct_exists(inst.variables, "image_xscale")
				image_xscale = inst.variables.image_xscale
			if struct_exists(inst.variables, "image_yscale")
				image_yscale = inst.variables.image_yscale
			
			var varnames = struct_get_names(inst.variables)
			for (var j = 0, m = array_length(varnames); j < m; j++)
			{
				var name = varnames[j]
				if array_contains(global.cyopIgnoredVariables, name)
					continue;
					
				var value = struct_get(inst.variables, name)
				var type = typeof(value)
				
				if (name == "flipX")
				{
					if value
					{
						x += sprite_width
						image_xscale *= -1
					}
					continue;
				}
				else if (name == "flipY")
				{
					if value
					{
						y += sprite_height
						image_yscale *= -1
					}
					continue;
				}
				
				array_push(variables, [name, value, type])
			}
		}
	}
	
	return true;
}