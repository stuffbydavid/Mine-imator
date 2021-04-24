/// vec4_homogenize(vector)
/// @arg vector

function vec4_homogenize(vec)
{
	return vec3(vec[X] / vec[W], vec[Y] / vec[W], vec[Z] / vec[W])
}
