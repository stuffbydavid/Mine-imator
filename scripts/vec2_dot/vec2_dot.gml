/// vec2_dot(vector1, vector2)
/// @arg vector1
/// @arg vector2

//gml_pragma("forceinline")

var v1, v2;
v1 = argument0
v2 = argument1

return v1[@ X] * v2[@ X] + v1[@ Y] * v2[@ Y]
