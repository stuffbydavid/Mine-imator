/// point3D_angle(from, to)
/// @arg from
/// @arg to

var dir, yaw, pitch;
dir = vec3_sub(argument1, argument0)
yaw = arctan2(dir[X], dir[Y]) * 180/pi
pitch = arctan2(sqrt(power(dir[X], 2) + power(dir[Y], 2)), dir[Z]) * 180/pi

return point3D(pitch, 0, yaw)
