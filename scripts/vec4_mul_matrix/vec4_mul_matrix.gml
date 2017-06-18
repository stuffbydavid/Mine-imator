/// vec4_mul_matrix(vector, matrix)
/// @arg vector
/// @arg matrix

gml_pragma("forceinline")

var vec, mat;
vec = argument0
mat = argument1

return vec4(
    mat[@ 0] * vec[@ X] + mat[@ 4] * vec[@ Y] + mat[@ 8] * vec[@ Z] + mat[@ 12] * vec[@ W], 
    mat[@ 1] * vec[@ X] + mat[@ 5] * vec[@ Y] + mat[@ 9] * vec[@ Z] + mat[@ 13] * vec[@ W], 
    mat[@ 2] * vec[@ X] + mat[@ 6] * vec[@ Y] + mat[@ 10] * vec[@ Z] + mat[@ 14] * vec[@ W], 
    mat[@ 3] * vec[@ X] + mat[@ 7] * vec[@ Y] + mat[@ 11] * vec[@ Z] + mat[@ 15] * vec[@ W]
)
