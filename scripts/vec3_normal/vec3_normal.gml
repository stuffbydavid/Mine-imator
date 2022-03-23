/// vec3_normal(vector, angle)
/// @arg vector
/// @arg angle
/// @desc Returns a normal vector based on given vector and angle.

function vec3_normal(vec, angle)
{
	var xx, yy, zz, cx, cy, t;
	xx = vec[X]
	yy = vec[Y]
	zz = vec[Z]
	
	cx = lengthdir_x(1, angle) / sqrt(xx * xx + yy * yy + zz * zz)
	cy = lengthdir_y(1, angle)
	
	t[Z] = cx * (xx * xx + yy * yy)
	t[Y] = cy * xx - cx * yy * zz
	t[X] = -cx * xx * zz - cy * yy
	
	return vec3_normalize(t)
}