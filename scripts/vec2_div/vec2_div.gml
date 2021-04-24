/// vec2_div(vector, divisor)
/// @arg vector
/// @arg divisor

function vec2_div(vec, d)
{
	if (is_array(d))
		return vec2(vec[@ X] / d[@ X], vec[@ Y] / d[@ Y])
	else
		return vec2(vec[@ X] / d, vec[@ Y] / d)
}
