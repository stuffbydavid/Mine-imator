/// CppSeparate ArrType array_add(VarType, VarType, BoolType merge = true)
/// @arg array
/// @arg value
/// @arg [merge]

function array_add(arr, val, merge = true)
{
	if (!is_array(arr))
		arr = []
	
	if (is_array(val) && merge)
	{
		for (var i = 0; i < array_length(val); i++)
			arr[@array_length(arr)] = val[@i]
	}
	else
		arr[@array_length(arr)] = val
	
	return arr
}
