/// @arg point
/// @arg planeorigin
/// @arg planenormal

function point3D_project_plane(pnt, planepos, planenormal)
{
	return point3D_sub(pnt, vec3_mul(planenormal, (vec3_dot(planenormal, pnt) + -vec3_dot(planenormal, planepos))))
}
