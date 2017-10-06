/// array(values...)
/// @arg values...

//gml_pragma("forceinline")

var arr = array_create(argument_count);
for (var a = 0; a < argument_count; a++)
	arr[a] = argument[a]
return arr
