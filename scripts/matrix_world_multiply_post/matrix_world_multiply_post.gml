/// matrix_world_multiply_post(matrix)
/// @arg matrix

function matrix_world_multiply_post(mat)
{
	gml_pragma("forceinline")
	
	matrix_set(matrix_world, matrix_multiply(matrix_get(matrix_world), mat))
}
