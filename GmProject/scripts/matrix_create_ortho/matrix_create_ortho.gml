/// CppSeparate MatrixType matrix_create_ortho(RealType, RealType, RealType, RealType, RealType, RealType)

function matrix_create_ortho(left, right, bottom, top, near, far)
{
	var mat = [ 2 / (right - left), 0, 0, -(right + left) / (right - left),
				0, 2 / (top - bottom), 0, -(top + bottom) / (top - bottom),
				0, 0, -2 / (far - near), -(far + near) / (far - near),
				0, 0, 0, 1 ];
	
	return matrix_transpose(mat)
}
