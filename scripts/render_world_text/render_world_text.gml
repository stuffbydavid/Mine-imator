/// draw_world_text(vbuffer, texture, facecamera, resource)
/// @arg vbuffer
/// @arg texture
/// @arg facecamera
/// @arg resource

var vbuffer, tex, facecamera, res;
var rot, sca, mipmap;
vbuffer = argument0
tex = argument1
facecamera = argument2
res = argument3

rot = vec3(0, 0, 0)
sca = vec3(1, 1, 1)

if (facecamera)
{
	var pos = point3D_mul_matrix(point3D(0, 0, 0), matrix_get(matrix_world));
	rot[X] -= point_zdirection(pos[X], pos[Y], pos[Z], proj_from[X], proj_from[Y], proj_from[Z])
	rot[Z] = 90 + point_direction(pos[X], pos[Y], proj_from[X], proj_from[Y])
}

if (!res.font_minecraft)
	sca = 8 / 48
	
matrix_add_offset()
matrix_world_multiply_pre(matrix_create(point3D(0, 0, 0), rot, sca))

mipmap = shader_texture_filter_mipmap
shader_texture_filter_mipmap = app.setting_transparent_texture_filtering
shader_texture = tex

shader_use()
vbuffer_render(vbuffer)

shader_texture_filter_mipmap = mipmap