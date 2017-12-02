/// vec2_mul(vector, multiplier)
/// @arg vector
/// @arg multiplier

var vec, mul;
vec = argument0
mul = argument1

if (is_array(mul))
	return vec2(vec[@ X] * mul[@ X], vec[@ Y] * mul[@ Y])
else
	return vec2(vec[@ X] * mul, vec[@ Y] * mul)