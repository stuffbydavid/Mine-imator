/// vec4_div(vector, divisor)
/// @arg vector
/// @arg divisor

function vec4_div(vec, d)
{
	if (is_array(d))
		return vec4(vec[@ X] / d[@ X], vec[@ Y] / d[@ Y], vec[@ Z] / d[@ Z], vec[@ W] / d[@ W])
	else
		return vec4(vec[@ X] / d, vec[@ Y] / d, vec[@ Z] / d, vec[@ W] / d)
}
