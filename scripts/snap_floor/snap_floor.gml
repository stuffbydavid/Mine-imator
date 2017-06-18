/// snap(value, x)
/// @arg value
/// @arg x

gml_pragma("forceinline")

if (argument1 = 0)
    return argument0
	
return floor(argument0 / argument1) * argument1
