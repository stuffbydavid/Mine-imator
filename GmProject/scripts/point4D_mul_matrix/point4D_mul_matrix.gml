/// CppSeparate VecType point4D_mul_matrix(VecType, MatrixType)
/// point4D_mul_matrix(point, matrix)
/// @arg point
/// @arg matrix

function point4D_mul_matrix(pnt, mat)
{
	gml_pragma("forceinline")
	
	return [
		mat[@ 0] * pnt[@ X] + mat[@ 4] * pnt[@ Y] + mat[@ 8] * pnt[@ Z] + mat[@ 12] * pnt[@ W], 
		mat[@ 1] * pnt[@ X] + mat[@ 5] * pnt[@ Y] + mat[@ 9] * pnt[@ Z] + mat[@ 13] * pnt[@ W], 
		mat[@ 2] * pnt[@ X] + mat[@ 6] * pnt[@ Y] + mat[@ 10] * pnt[@ Z] + mat[@ 14] * pnt[@ W], 
		mat[@ 3] * pnt[@ X] + mat[@ 7] * pnt[@ Y] + mat[@ 11] * pnt[@ Z] + mat[@ 15] * pnt[@ W]
	]
}
