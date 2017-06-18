/// percent(value, start, end)
/// @arg value
/// @arg start
/// @arg end

gml_pragma("forceinline")

if (argument1 = argument2) 
	return (argument0 < argument1)
	
return clamp((argument0 - argument1) / (argument2 - argument1), 0, 1)
