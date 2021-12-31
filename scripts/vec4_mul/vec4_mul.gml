/// vec4_mul(vector, mul)
/// @arg vector
/// @arg mul

function vec4_mul(vec, m)
{
	if (is_array(m))
		return [vec[@ X] * m[@ X], vec[@ Y] * m[@ Y], vec[@ Z] * m[@ Z], vec[@ W] * m[@ W]]
	else
		return [vec[@ X] * m, vec[@ Y] * m, vec[@ Z] * m, vec[@ W] * m]
}
