/// point3D_project_plane(pos, planepos, normal)
/// @arg pos
/// @arg planepos
/// @arg normal

function point3D_project_plane(pos, planepos, n)
{
	return point3D_sub(pos, vec3_mul(n, (vec3_dot(n, pos) + -vec3_dot(n, planepos))))
}