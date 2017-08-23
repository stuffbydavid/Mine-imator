/// ds_list_delete_value(id, value)
/// @arg id
/// @arg value

var index = ds_list_find_index(argument0, argument1)
if (index >= 0)
	ds_list_delete(argument0, index)
