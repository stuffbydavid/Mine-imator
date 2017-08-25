/// json_export_array(array, size)
/// @arg array
/// @arg valuetype

var arr, size;
arr = argument0
size = argument1

json_string += "[ "
for (var i = 0; i < size; i++)
{
	if (i > 0)
		json_string += ", "
	json_export_value(arr[@i])
}
json_string += " ]"