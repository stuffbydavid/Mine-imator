/// vec2_div(vector, divisor)
/// @arg vector
/// @arg divisor

//gml_pragma("forceinline")

var vec, d, ret;
vec = argument0
d = argument1

if (is_array(d))
	return vec2(vec[@ X] / d[@ X], vec[@ Y] / d[@ Y])
else
	return vec2(vec[@ X] / d, vec[@ Y] / d)
