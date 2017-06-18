/// matrix_remove_rotation(matrix)
/// @arg matrix
/// @desc Removes all rotation from the matrix.

var mat, xsca, ysca, zsca;
mat = argument0

xsca = sqrt(mat[0] * mat[0] + mat[1] * mat[1] + mat[2] * mat[2])
ysca = sqrt(mat[4] * mat[4] + mat[5] * mat[5] + mat[6] * mat[6])
zsca = sqrt(mat[8] * mat[8] + mat[9] * mat[9] + mat[10] * mat[10])

mat[@ 0] = xsca
mat[@ 1] = 0
mat[@ 2] = 0
mat[@ 4] = 0
mat[@ 5] = ysca
mat[@ 6] = 0
mat[@ 8] = 0
mat[@ 9] = 0
mat[@ 10] = zsca
