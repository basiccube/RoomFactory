///@param {String} name
///@param {String} path
///@param {Real} offsetX
///@param {Real} offsetY
function ConfigAssetSpriteData(sprName, sprPath, offX = 0, offY = 0) constructor
{
	name = sprName
	path = sprPath
	
	sprite = undefined
	spriteLoaded = false
	
	offsetX = offX
	offsetY = offY
	
	static LoadSprite = function()
	{
		if !spriteLoaded
		{
			sprite = sprite_add(path, 1, false, false, offsetX, offsetY)
			spriteLoaded = true
		}
	}
	
	static GetSprite = function()
	{
		if !spriteLoaded
			LoadSprite()
			
		return sprite;
	}
}

function ConfigAssetSprites() constructor
{
	static map = ds_map_create()
	
	///@param {String} name
	static CreateCategory = function(name)
	{
		if !ds_map_exists(map, name)
			ds_map_set(map, name, {})
	}
	
	///@param {String} name
	static CategoryExists = function(name)
	{ return ds_map_exists(map, name); }
	
	///@param {String} name
	static GetCategory = function(name)
	{
		if !ds_map_exists(map, name)
		{
			print($"Category {name} doesn't exist!")
			return undefined;
		}
		
		return map[? name];
	}
	
	///@param {String} name
	///@param {Struct.ConfigAssetSpriteData} data
	static AddSpriteData = function(name, data)
	{
		var cat = GetCategory(name)
		if is_undefined(cat)
			exit;
		
		print($"Adding sprite {data.name} to category {name}")
		cat[$ data.name] = data
	}
	
	static ClearSprites = function()
	{
		var key = ds_map_find_first(map)
		for (var i = 0, n = ds_map_size(map); i < n; i++)
		{
			var cat = ds_map_find_value(map, key)
			struct_foreach(cat, function(name, value)
			{
				print($"Deleting sprite {name}")
				if (value.spriteLoaded && sprite_exists(value.sprite))
					sprite_delete(value.sprite)
			})
				
			key = ds_map_find_next(map, key)
		}
		ds_map_clear(map)
	}
	
	static FindConfigSprites = function()
	{
		var configName = filename_change_ext(global.configFileName, "")
		var dirPath = $"{CONFIG_PATH}{configName}"
		
		if !directory_exists(dirPath)
			exit;
			
		var sprDirPath = $"{dirPath}/sprites"
		if !directory_exists(sprDirPath)
			exit;
			
		print("Scanning for asset layer sprites...")
		
		var dirList = []
		static addSpritesInDir = function(dir)
		{
			var dirName = dir[0]
			var dirPath = dir[1]
			
			var file = file_find_first($"{dirPath}/*.png", fa_none)
			while (file != "")
			{
				var name = filename_change_ext(file, "")
				var path = $"{dirPath}/{file}"
				
				if !ds_map_exists(map, dirName)
					ds_map_set(map, dirName, {})
				
				var spriteData = new ConfigAssetSpriteData(name, path)
				AddSpriteData(dirName, spriteData)
				
				file = file_find_next()
			}
			file_find_close()
		}
		
		var file = file_find_first($"{sprDirPath}/*", fa_directory)
		while (file != "")
		{
			array_push(dirList, [file, $"{sprDirPath}/{file}"])
			file = file_find_next()
		}
		file_find_close()
		
		for (var i = 0, n = array_length(dirList); i < n; i++)
			addSpritesInDir(dirList[i])
	}
}

static_get(new ConfigAssetSprites())