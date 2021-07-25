/// vec3_add(vector1, vector2)
/// @arg vector1
/// @arg vector2

function vec3_add(v1, v2)
{
	return [v1[@ X] + v2[@ X], v1[@ Y] + v2[@ Y], v1[@ Z] + v2[@ Z]]
}
