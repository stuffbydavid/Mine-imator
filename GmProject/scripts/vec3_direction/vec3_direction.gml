/// vec3_direction(from, to)
/// @arg from
/// @arg to

function vec3_direction(from, to)
{
	var v = vec3_normalize(point3D_sub(to, from));
	
	if (vec3_length(v) = 0)
		return [0, 1, 0]
	else
		return v
}