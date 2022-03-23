/// vec3_direction(from, to)
/// @arg from
/// @arg to

function vec3_direction(from, to)
{
	return vec3_normalize(point3D_sub(to, from))
}