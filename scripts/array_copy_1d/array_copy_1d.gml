/// array_copy_1d(array)
/// @arg array

//gml_pragma("forceinline")

if (array_length_1d(argument0) = 0)
	return array()

argument0[0] = argument0[0]
return argument0
