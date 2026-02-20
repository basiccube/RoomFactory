globalvar tempMeetingList;
tempMeetingList = ds_list_create()

function print()
{
	var _string = ""
	for (var i = 0; i < argument_count; i++)
		_string += string(argument[i])
	
	show_debug_message(_string)
}

function concat()
{
	var _string = ""
	for (var i = 0; i < argument_count; i++)
		_string += string(argument[i])
	
	return _string;
}

function func_empty()
{
	
}

function instance_destroy_array(arr)
{
	for (var i = 0, n = array_length(arr); i < n; i++)
	{
		var inst = arr[i]
		if instance_exists(inst)
			instance_destroy(inst)
	}
}

function file_text_read_all(file)
{
    if is_string(file)
    {
		if !file_exists(file)
			return "";
		
        var buff = buffer_load(file)
        var text = buffer_read(buff, buffer_text)		
        buffer_delete(buff)
		
        return text;
    }
	
    var filestring = ""
    while !file_text_eof(file)
        filestring += file_text_readln(file)
		
    return filestring;
}

function create_placeholder_sprite(size = 16)
{
	var spr = undefined
	var surf = surface_create(size, size)
	
	surface_set_target(surf)
	draw_clear_alpha(c_black, 0)
	
	var p = size / 2
	var c = make_color_hsv(irandom(255), 255, 255)
	draw_circle_color(p, p, p, c, c, false)
	draw_circle(p, p, p, true)
	
	surface_reset_target()
	
	spr = sprite_create_from_surface(surf, 0, 0, size, size, false, false, 0, 0)
	surface_free(surf)
	
	return spr;
}