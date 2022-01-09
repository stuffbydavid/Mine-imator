/// array_copy_1d(array)
/// @arg array

function array_copy_1d(arr)
{
	if (!is_array(arr))
		return []
	
	var newarr = [];
	array_copy(newarr, 0, arr, 0, array_length(arr))
	return newarr
}
