/// vec3_mul_matrix(vector, matrix)
/// @arg vector
/// @arg matrix

function vec3_mul_matrix(vec, mat)
{
	return [mat[@ 0] * vec[@ X] + mat[@ 4] * vec[@ Y] + mat[@ 8]  * vec[@ Z],
			mat[@ 1] * vec[@ X] + mat[@ 5] * vec[@ Y] + mat[@ 9]  * vec[@ Z],
			mat[@ 2] * vec[@ X] + mat[@ 6] * vec[@ Y] + mat[@ 10] * vec[@ Z]]
}
