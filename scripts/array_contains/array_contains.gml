/// array_contains(array, value)
/// @arg array
/// @arg value

gml_pragma("forceinline")

for (var i = 0; i < array_length_1d(argument0); i++)
	if (argument0[@ i] = argument1)
		return true
		
return false