/// vbuffer_render_matrix(vbuffer, matrix)
/// @arg vbuffer
/// @arg matrix

function vbuffer_render_matrix(vbuf, mat)
{
	matrix_set(matrix_world, mat)
	vertex_submit(vbuf, pr_trianglelist, -1)
	matrix_world_reset()
}
