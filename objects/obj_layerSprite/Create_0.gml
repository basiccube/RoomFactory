event_inherited()

spriteName = ""
spriteElement = undefined

savedDragAlpha = 1

onDragStart = function()
{
	savedDragAlpha = layer_sprite_get_alpha(spriteElement)
	layer_sprite_alpha(spriteElement, 0)
	visible = true
}

onDragEnd = function()
{
	layer_sprite_x(spriteElement, x)
	layer_sprite_y(spriteElement, y)
	
	layer_sprite_alpha(spriteElement, savedDragAlpha)
	visible = false
}