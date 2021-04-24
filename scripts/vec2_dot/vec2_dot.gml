/// vec2_dot(vector1, vector2)
/// @arg vector1
/// @arg vector2

function vec2_dot(v1, v2)
{
	return v1[@ X] * v2[@ X] + v1[@ Y] * v2[@ Y]
}
