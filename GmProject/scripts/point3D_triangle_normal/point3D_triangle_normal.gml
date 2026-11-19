/// @arg point1
/// @arg point2
/// @arg point3

function point3D_triangle_normal(p1, p2, p3)
{
	return vec3_normalize(vec3_cross(point3D_mul(p1, p3), point3D_mul(p2, p3)))
}
