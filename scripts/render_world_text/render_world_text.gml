/// render_world_text(vbuffer, texture, facecamera, resource)
/// @arg vbuffer
/// @arg texture
/// @arg facecamera
/// @arg resource

var vbuffer, tex, facecamera, res;
vbuffer = argument0
tex = argument1
facecamera = argument2
res = argument3

if (facecamera)
{
	var mat, rotx, rotz;
	mat = matrix_get(matrix_world)
	rotx = -point_zdirection(mat[MAT_X], mat[MAT_Y], mat[MAT_Z], proj_from[X], proj_from[Y], proj_from[Z])
	rotz = 90 + point_direction(mat[MAT_X], mat[MAT_Y], proj_from[X], proj_from[Y])
	matrix_world_multiply_pre(matrix_build(0, 0, 0, rotx, 0, rotz, 1, 1, 1))
}

if (!res.font_minecraft)
{
	var sca = 8 / 48;
	matrix_world_multiply_pre(matrix_build(0, 0, 0, 0, 0, 0, sca, 1, sca))
}
	
render_set_texture(tex)

vbuffer_render(vbuffer)