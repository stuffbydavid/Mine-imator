/// vec3_rotate_axis_angle(v, axis, angle)
/// @arg v
/// @arg axis
/// @arg angle

function vec3_rotate_axis_angle(v, axis, angle)
{
	var d, r;
	d = vec3_mul(axis, vec3_dot(v, axis))
	r = vec3_sub(v, d)
	
	return vec3_add(d, vec3_add(vec3_mul(r, cos(angle)), vec3_mul(vec3_cross(axis, r), sin(angle))))
}