/// array_add(array, values, [merge])
/// @arg array
/// @arg value
/// @arg [merge]

function array_add(arr, val, merge = true)
{
	if (!is_array(arr))
		arr = array()
	
	if (is_array(val) && merge)
	{
		for (var i = 0; i < array_length(val); i++)
			arr[@array_length(arr)] = val[@i]
	}
	else
		arr[@array_length(arr)] = val
	
	return arr
}
