/// point3D_triangle_normal(p1, p2, p3)
/// @arg p1
/// @arg p2
/// @arg p3

function point3D_triangle_normal(p1, p2, p3)
{
	return vec3_normalize(vec3_cross(point3D_mul(p1, p3), point3D_mul(p2, p3)))
}