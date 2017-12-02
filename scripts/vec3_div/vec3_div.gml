/// vec3_div(vector, divisor)
/// @arg vector
/// @arg divisor

var vec, d;
vec = argument0
d = argument1

if (is_array(d))
	return vec3(vec[@ X] / d[@ X], vec[@ Y] / d[@ Y], vec[@ Z] / d[@ Z])
else
	return vec3(vec[@ X] / d, vec[@ Y] / d, vec[@ Z] / d)
