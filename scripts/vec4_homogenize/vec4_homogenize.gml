/// vec4_homogenize(vector)
/// @arg vector

function vec4_homogenize(vec)
{
	return [vec[X] / vec[W], vec[Y] / vec[W], vec[Z] / vec[W]]
}
