/// interpolate(function, d, x1, x2)
/// @arg function
/// @arg d
/// @arg x1
/// @arg x2

gml_pragma("forceinline")

return argument2 + ease(argument0, argument1) * (argument3 - argument2)
