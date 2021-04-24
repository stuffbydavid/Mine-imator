/// array_copy_1d(array)
/// @arg array

function array_copy_1d(arr)
{
	if (array_length(arr) = 0)
		return array()
	
	var newarr = array();
	array_copy(newarr, 0, arr, 0, array_length(arr))
	return newarr
}
