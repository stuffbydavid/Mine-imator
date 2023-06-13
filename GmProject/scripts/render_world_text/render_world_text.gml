/// render_world_text(vbuffer, texture, facecamera, resource, outline)
/// @arg vbuffer
/// @arg texture
/// @arg facecamera
/// @arg resource

function render_world_text(vbuffer, tex, facecamera, res, outline)
{
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
	
	render_set_texture(tex[0])
	vbuffer_render(vbuffer[0])
	
	if (outline != null)
	{
		render_set_uniform_color("uBlendColor", outline, shader_blend_alpha)
		render_set_texture(tex[1])
		vbuffer_render(vbuffer[1])
		render_set_uniform_color("uBlendColor", shader_blend_color, shader_blend_alpha)
	}
}
