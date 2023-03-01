/// point3D_angle(from, to)
/// @arg from
/// @arg to

function point3D_angle(from, to)
{
	var dir, yaw, pitch;
	dir = vec3_sub(to, from)
	yaw = arctan2(dir[X], dir[Y]) * 180/pi
	pitch = arctan2(sqrt(power(dir[X], 2) + power(dir[Y], 2)), dir[Z]) * 180/pi
	
	return [pitch, 0, yaw]
}
