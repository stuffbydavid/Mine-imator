/// vec3_div(vector, divisor)
/// @arg vector
/// @arg divisor

gml_pragma("forceinline")

var vec, d;
vec = argument0
d = argument1

return vec3(vec[@ X] / d, vec[@ Y] / d, vec[@ Z] / d)
