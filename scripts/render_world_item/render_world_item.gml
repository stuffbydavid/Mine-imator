/// render_world_item(vbuffer, is3d, facecamera, bounce, rotate, resource)
/// @arg vbuffer
/// @arg is3d
/// @arg facecamera
/// @arg bounce
/// @arg rotate
/// @arg resource

var vbuffer, is3d, facecamera, bounce, rotate, res;
vbuffer = argument0
is3d = argument1
facecamera = argument2
bounce = argument3
rotate = argument4
res = argument5

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

if (rotate)
{
	var d, t, offz, mat, rotz, rotmat;
	d = 60 * 6
	t = app.background_time mod d * 360
	offz = t/360
	mat = matrix_get(matrix_world)
	rotmat = matrix_build(-8, -0.5 * is3d, 0, 0, 0, 0, 1, 1, 1);
	rotmat = matrix_multiply(rotmat, matrix_build(8, 0.5 * is3d, 0, 0, 0, offz, 1, 1, 1))
	matrix_world_multiply_pre(rotmat)
}

if (bounce)
{
	var d, t, offz;
	d = 60 * 3
	t = app.background_time mod d * 2
	if (t < d)
		offz = ease("easeinoutquad", t / d) * 2 - 1
	else
		offz = 1 - ease("easeinoutquad", (t - d) / d) * 2
	matrix_world_multiply_post(matrix_build(0, 0, offz, 0, 0, 0, 1, 1, 1))
}

if (res.item_sheet_texture != null)
	render_set_texture(res.item_sheet_texture)
else
	render_set_texture(res.texture)

vbuffer_render(vbuffer)