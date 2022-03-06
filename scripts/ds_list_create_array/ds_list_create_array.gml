/// ds_list_create_array(id)
/// @arg id
/// @desc Converts a ds list to an array and returns it

function ds_list_create_array(list)
{
	var arr = array();
	
	for (var i = 0; i < ds_list_size(list); i++)
	{
		if (is_array(list[|i]))
			array_add(arr, array_copy_1d(list[|i]), false)
		else
			array_add(arr, list[|i], false)
	}
	
	return arr
}
