/// ds_list_delete_value(id, value)
/// @arg id
/// @arg value

function ds_list_delete_value(list, val)
{
	var index = ds_list_find_index(list, val)
	
	if (index >= 0)
		ds_list_delete(list, index)
}
