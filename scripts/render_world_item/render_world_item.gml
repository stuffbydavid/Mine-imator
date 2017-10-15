/// render_world_item(vbuffer, is3d, facecamera, bounce, resource)
/// @arg vbuffer
/// @arg is3d
/// @arg facecamera
/// @arg bounce
/// @arg resource

var vbuffer, is3d, facecamera, bounce, res;
vbuffer = argument0
is3d = argument1
facecamera = argument2
bounce = argument3
res = argument4

if (!res.ready)
	res = mc_res

if (facecamera)
{
	var mat, rotz, rotmat;
	mat = matrix_get(matrix_world)
	rotz = 90 + point_direction(mat[MAT_X], mat[MAT_Y], proj_from[X], proj_from[Y])
	rotmat = matrix_build(-8, -0.5 * is3d, 0, 0, 0, 0, 1, 1, 1);
	rotmat = matrix_multiply(rotmat, matrix_build(8, 0.5 * is3d, 0, 0, 0, rotz, 1, 1, 1))
	matrix_world_multiply_pre(rotmat)
}

if (bounce)
{
	var d, t, offz;
	d = 60 * 2
	t = current_step mod d * 2
	if (t < d)
		offz = ease("easeinoutquad", t / d) * 2 - 1
	else
		offz = 1 - ease("easeinoutquad", (t - d) / d) * 2
	matrix_world_multiply_post(matrix_build(0, 0, offz, 0, 0, 0, 1, 1, 1))
}

var mipmap = shader_texture_filter_mipmap;
shader_texture_filter_mipmap = app.setting_transparent_texture_filtering

if (res.item_sheet_texture != null)
	render_set_texture(res.item_sheet_texture)
else
	render_set_texture(res.texture)

vbuffer_render(vbuffer)

shader_texture_filter_mipmap = mipmap