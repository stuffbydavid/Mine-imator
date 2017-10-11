/// array_add(array, values)
/// @arg array
/// @arg value

var arr, val;
arr = argument0
val = argument1

if (!is_array(arr))
	arr = array()
	
if (is_array(val))
{
	for (var i = 0; i < array_length_1d(val); i++)
		arr[@array_length_1d(arr)] = val[@i]
}
else
	arr[@array_length_1d(arr)] = val

return arr