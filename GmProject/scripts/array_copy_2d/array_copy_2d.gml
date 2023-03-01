/// CppSeparate ArrType array_copy_2d(ArrType)
/// array_copy_2d(array)
/// @arg array

function array_copy_2d(arr)
{
	var newarr = array();
	
	for (var i = 0; i < array_length(arr); i++)
		for (var j = 0; j < array_length(arr[i]); j++)
			newarr[i][j] = arr[i][j]
	
	return newarr
}
