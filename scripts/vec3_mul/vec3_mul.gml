/// vec3_mul(vector, multiplier)
/// @arg vector
/// @arg multiplier

gml_pragma("forceinline")

var vec, mul;
vec = argument0
mul = argument1
 
if (is_array(mul))
	return vec3(vec[@ X] * mul[@ X], vec[@ Y] * mul[@ Y], vec[@ Z] * mul[@ Z])
else
	return vec3(vec[@ X] * mul, vec[@ Y] * mul, vec[@ Z] * mul)
