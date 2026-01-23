#macro MAX_RECENTS 6
global.recents = array_create(MAX_RECENTS, undefined)

///@param {String} file
function recents_push(file)
{
	if array_contains(global.recents, file)
		exit;
	
	array_insert(global.recents, 0, file)
	array_pop(global.recents)
}