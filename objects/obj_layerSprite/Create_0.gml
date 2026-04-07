event_inherited()

spriteName = ""

spriteAlpha = 1
spriteIndex = 0
spriteSpeed = 1

preview = false

startPreview = function()
{
	preview = true
	image_index = spriteIndex
	image_speed = spriteSpeed
}

stopPreview = function()
{
	preview = false
	image_index = 0
	image_speed = 0
}

onDragEnd = function()
{ image_alpha = spriteAlpha; }

onAlphaUpdate = function()
{ image_alpha = spriteAlpha; }

onDraw = function()
{
	if preview
		image_speed = spriteSpeed
	
	draw_sprite_ext(
		sprite_index,
		preview ? image_index : spriteIndex,
		x,
		y,
		image_xscale,
		image_yscale,
		image_angle,
		image_blend,
		image_alpha
	)
}