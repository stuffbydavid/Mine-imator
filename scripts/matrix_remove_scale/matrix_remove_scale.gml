/// matrix_remove_scale(matrix)
/// @arg matrix
/// @desc Removes all scaling from the matrix.

var mat, xsca, ysca, zsca;
mat = argument0

xsca = sqrt(mat[0] * mat[0] + mat[1] * mat[1] + mat[2] * mat[2])
ysca = sqrt(mat[4] * mat[4] + mat[5] * mat[5] + mat[6] * mat[6])
zsca = sqrt(mat[8] * mat[8] + mat[9] * mat[9] + mat[10] * mat[10])

if (xsca * ysca * zsca > 0)
{
	mat[@ 0] /= xsca
	mat[@ 1] /= xsca
	mat[@ 2] /= xsca
	mat[@ 4] /= ysca
	mat[@ 5] /= ysca
	mat[@ 6] /= ysca
	mat[@ 8] /= zsca
	mat[@ 9] /= zsca
	mat[@ 10] /= zsca
}
