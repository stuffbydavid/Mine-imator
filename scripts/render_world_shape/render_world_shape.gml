/// render_world_shape(type, vbuffer, facecamera, textures)
/// @arg type
/// @arg vbuffer
/// @arg facecamrea
/// @arg textures

function render_world_shape(type, vbuf, facecamera, tex)
{
	if (type = e_temp_type.SURFACE && facecamera)
	{
		var mat, rotx, rotz;
		mat = matrix_get(matrix_world);
		rotx = -point_zdirection(mat[MAT_X], mat[MAT_Y], mat[MAT_Z], proj_from[X], proj_from[Y], proj_from[Z])
		rotz = 90 + point_direction(mat[MAT_X], mat[MAT_Y], proj_from[X], proj_from[Y])
		matrix_world_multiply_pre(matrix_build(0, 0, 0, rotx, 0, rotz, 1, 1, 1))
	}
	
	render_set_texture(tex[0])
	
	if (tex[1] != spr_default_material)
	{
		if (shader_uniform_metallic != 1)
		{
			shader_uniform_metallic = 1
			render_set_uniform("uMetallic", shader_uniform_metallic)
		}
		
		if (shader_uniform_roughness != 0)
		{
			shader_uniform_roughness = 0
			render_set_uniform("uRoughness", shader_uniform_roughness)
		}
		
		if (shader_uniform_emissive != 1)
		{
			shader_uniform_emissive = 1
			render_set_uniform("uEmissive", shader_uniform_emissive)
		}
		
		render_set_texture(tex[1], "Material")
	}
	
	render_set_texture(tex[2], "Normal")
	vbuffer_render(vbuf)
}
