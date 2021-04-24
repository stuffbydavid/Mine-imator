/// array_add(array, values)
/// @arg array
/// @arg value

function array_add(arr, val)
{
	if (!is_array(arr))
		arr = array()
	
	if (is_array(val))
	{
		for (var i = 0; i < array_length(val); i++)
			arr[@array_length(arr)] = val[@i]
	}
	else
		arr[@array_length(arr)] = val
	
	return arr
}
