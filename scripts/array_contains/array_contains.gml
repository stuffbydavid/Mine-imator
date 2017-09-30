/// array_contains(array, value)
/// @arg array
/// @arg value

//gml_pragma("forceinline")

var arr, value, len;
arr = argument0
value = argument1
len = array_length_1d(argument0)

for (var i = 0; i < len; i++)
	if (arr[@ i] = value)
		return true
		
return false