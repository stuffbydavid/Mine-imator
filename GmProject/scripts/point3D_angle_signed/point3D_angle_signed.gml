/// point3D_angle_signed(from, to, axis)
/// @arg from
/// @arg to
/// @arg axis

function point3D_angle_signed(from, to, axis)
{
	return point3D_angle_deg(from, to) * sign(vec3_dot(axis, vec3_cross(from, to)))
}