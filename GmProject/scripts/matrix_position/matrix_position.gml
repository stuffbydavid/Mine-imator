/// CppSeparate VecType matrix_position(MatrixType)
/// @arg matrix

function matrix_position(mat)
{
	gml_pragma("forceinline")
	
	return point3D(mat[MAT_X], mat[MAT_Y], mat[MAT_Z])
}
