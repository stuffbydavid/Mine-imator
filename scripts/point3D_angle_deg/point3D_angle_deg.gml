/// point3D_angle_deg(from, to)
/// @arg from
/// @arg to
/// @desc Returns angle in degrees between from and to

function point3D_angle_deg(from, to)
{
	var d = vec3_length(from) * vec3_length(to);
	
	if (d < 0.0001)
		return 0
	
	return radtodeg(arccos(clamp(vec3_dot(from, to) / d, -1, 1)))
}
