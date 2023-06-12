/// matrix_create_axis_angle(axis, angle)
/// @arg axis
/// @arg angle
/// @desc https://www.bloomenthal.com/JBloom/pdf/ref-frames.pdf

function matrix_create_axis_angle(axis, angle)
{
	var sq, angle1, xy, yz, zx, s, angles, mat;
	sq		= vec3_mul(axis, axis)
	angle1	= 1 - angle
	xy		= axis[X] * axis[Y] * angle1
	yz		= axis[Y] * axis[Z] * angle1
	zx		= axis[X] * axis[Z] * angle1
	s		= sqrt(max(0, 1 - power(angle, 2)))
	angles[X] = axis[X] * s
	angles[Y] = axis[Y] * s
	angles[Z] = axis[Z] * s
	
	mat =  [ (sq[X] + (1 - sq[X]) * angle),	xy + angles[Z],					zx - angles[Y],					0,
			 xy - angles[Z],				(sq[Y] + (1 - sq[Y]) * angle),	yz + angles[X],					0,
			 zx + angles[Y],				yz - angles[X],					(sq[Z] + (1 - sq[Z]) * angle),  0,
			 0,								0,								0,								1 ]
	
	return mat
}