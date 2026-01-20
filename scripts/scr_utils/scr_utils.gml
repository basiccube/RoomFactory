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