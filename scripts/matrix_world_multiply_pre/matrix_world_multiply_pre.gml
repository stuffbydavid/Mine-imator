/// matrix_world_multiply_pre(matrix)
/// @arg matrix

function matrix_world_multiply_pre(mat)
{
	gml_pragma("forceinline")
	
	matrix_set(matrix_world, matrix_multiply(mat, matrix_get(matrix_world)))
}
