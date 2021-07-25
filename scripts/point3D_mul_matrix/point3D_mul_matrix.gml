/// point3D_mul_matrix(point, matrix)
/// @arg point
/// @arg matrix

function point3D_mul_matrix(pnt, mat)
{
	return [mat[@ 0] * pnt[@ X] + mat[@ 4] * pnt[@ Y] + mat[@ 8]  * pnt[@ Z] + mat[@ 12],
			mat[@ 1] * pnt[@ X] + mat[@ 5] * pnt[@ Y] + mat[@ 9]  * pnt[@ Z] + mat[@ 13],
			mat[@ 2] * pnt[@ X] + mat[@ 6] * pnt[@ Y] + mat[@ 10] * pnt[@ Z] + mat[@ 14]]
}
