/// vec4_min(vec1, vec2)
/// @arg vec1
/// @arg vec2

function vec4_min(v1, v2)
{
	return [min(v1[X], v2[X]), min(v1[Y], v2[Y]), min(v1[Z], v2[Z]), min(v1[W], v2[W])]
}
