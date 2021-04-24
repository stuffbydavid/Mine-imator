/// uv_rotate(uv, angle, offset)
/// @arg uv
/// @arg angle
/// @arg offset
/// @arg scale

function uv_rotate(uv, angle, offset)
{
	var rotmat, pnt;
	rotmat = matrix_create(point3D(-offset[@ X], -offset[@ Y], 0), vec3(0), vec3(1))
	rotmat = matrix_multiply(rotmat, matrix_create(point3D(offset[@ X], offset[@ Y], 0), vec3(0, 0, angle), vec3(1)))
	
	pnt = point3D_mul_matrix(point3D(uv[@ X], uv[@ Y], 0), rotmat)
	
	return point2D(pnt[X], pnt[Y])
}
