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
	res = res_def

var rot, off, mipmap;
rot = vec3(0)
off = point3D(0, 0, 0)

if (bounce)
{
	var d, t;
	d = 60 * 2
	t = current_step mod d * 2
	if (t < d)
		off[Z] = ease("easeinoutquad", t / d) * 2 - 1
	else
		off[Z] = 1 - ease("easeinoutquad", (t - d) / d) * 2
}

if (facecamera)
{
	var pos = point3D_mul_matrix(point3D(0, 0, 0), matrix_get(matrix_world));
	rot[Z] = 90 + point_direction(pos[X], pos[Y], proj_from[X], proj_from[Y])
}

var rotmat = matrix_create(point3D(-8, -0.5 * is3d, 0), vec3(0), vec3(1));
rotmat = matrix_multiply(rotmat, matrix_create(point3D(8, 0.5 * is3d, 0), rot, vec3(1)))
matrix_world_multiply_pre(rotmat)
matrix_world_multiply_post(matrix_create(off, vec3(0), vec3(1)))

mipmap = shader_texture_filter_mipmap
shader_texture_filter_mipmap = app.setting_transparent_texture_filtering

if (res.item_sheet_texture != null)
	shader_texture = res.item_sheet_texture
else
	shader_texture = res.texture

shader_use()
vbuffer_render(vbuffer)

shader_texture_filter_mipmap = mipmap