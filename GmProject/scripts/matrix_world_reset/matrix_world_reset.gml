/// matrix_world_reset()

function matrix_world_reset()
{
	gml_pragma("forceinline")
	
	matrix_set(matrix_world, MAT_IDENTITY)
}
