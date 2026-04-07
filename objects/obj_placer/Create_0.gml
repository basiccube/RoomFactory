layerName = "Instances"
layerType = CONFIG_LAYER_INSTANCE

getLayer = function()
{ return layer_get_id(layerName); }

createLayer = function()
{
	var layInfo = config_get_layer(layerName)
	if !layer_exists(layerName)
		return layer_create(layInfo.depth, layerName);
	
	return getLayer();
}

objectData = undefined
objectPlace = function()
{
	var lay = createLayer()
	create_room_object(x, y, lay, objectData)
}

objectDraw = function()
{
	var spr = config_get_object_sprite(objectData)
	if (spr != undefined)
		draw_sprite_ext(spr, 0, mouse_x, mouse_y, 1, 1, 0, c_white, 0.5)
}

assetSprite = undefined
assetPlace = function()
{
	var lay = createLayer()
	var spr = assetSprite.GetSprite()
	
	with (instance_create_layer(x, y, lay, obj_layerSprite))
	{
		sprite_index = spr
		spriteName = other.assetSprite.name
	}
}

assetDraw = function()
{
	if (assetSprite != undefined)
		draw_sprite_ext(assetSprite.GetSprite(), 0, mouse_x, mouse_y, 1, 1, 0, c_white, 0.5)
}