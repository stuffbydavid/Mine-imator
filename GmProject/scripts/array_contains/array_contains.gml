/// CppSeparate BoolType array_contains(VarType, VarType)
/// array_contains(array, value)
/// @arg array
/// @arg value

function array_contains(arr, value)
{
	var len = array_length(arr);
	
	for (var i = 0; i < len; i++)
		if (arr[@ i] = value)
			return true
	
	return false
}
