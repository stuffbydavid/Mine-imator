/// vbuffer_render_matrix(vbuffer, matrix)
/// @arg vbuffer
/// @arg matrix

var vbuf, mat;
vbuf = argument0
mat = argument1

matrix_set(matrix_world, mat)
vertex_submit(vbuf, pr_trianglelist, -1)
matrix_world_reset()
