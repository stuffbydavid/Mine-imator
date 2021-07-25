/// vec3_mul(vector, multiplier)
/// @arg vector
/// @arg multiplier

function vec3_mul(vec, mul)
{
	if (is_array(mul))
		return [vec[@ X] * mul[@ X], vec[@ Y] * mul[@ Y], vec[@ Z] * mul[@ Z]]
	else
		return [vec[@ X] * mul, vec[@ Y] * mul, vec[@ Z] * mul]
}
