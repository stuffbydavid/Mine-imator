/// ds_list_delete_value(id, value)
/// @arg id
/// @arg value

var pos = ds_list_find_index(argument0, argument1)
if (pos >= 0)
	ds_list_delete(argument0, pos)
