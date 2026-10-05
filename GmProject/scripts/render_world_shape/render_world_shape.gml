/// @arg type
/// @arg vertexbuffer
/// @arg facecamera
/// @arg textures

function render_world_shape(type, vbuf, facecamera, tex)
{
	if (type = e_temp_type.SURFACE && facecamera)
	{
		var mat, rotx, rotz;
		mat = matrix_get(matrix_world)
		rotx = -point_zdirection(mat[MAT_X], mat[MAT_Y], mat[MAT_Z], proj_from[X], proj_from[Y], proj_from[Z])
		rotz = 90 + point_direction(mat[MAT_X], mat[MAT_Y], proj_from[X], proj_from[Y])
		matrix_world_multiply_pre(matrix_build(0, 0, 0, rotx, 0, rotz, 1, 1, 1))
	}
	
	render_set_texture(tex[e_texture_channel.DIFFUSE])
	
	shader_texture_surface = false
	if (!render_depth_pass)
	{
		render_set_texture(tex[e_texture_channel.MATERIAL], e_texture_channel.MATERIAL)
		render_set_texture(tex[e_texture_channel.NORMAL], e_texture_channel.NORMAL)
	}
	vbuffer_render(vbuf)
}
