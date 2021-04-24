/// vec2_mul(vector, multiplier)
/// @arg vector
/// @arg multiplier

function vec2_mul(vec, mul)
{
	if (is_array(mul))
		return vec2(vec[@ X] * mul[@ X], vec[@ Y] * mul[@ Y])
	else
		return vec2(vec[@ X] * mul, vec[@ Y] * mul)
}
