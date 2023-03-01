/// render_world_item(vbuffer, is3d, facecamera, bounce, rotate, resource)
/// @arg vbuffer
/// @arg is3d
/// @arg facecamera
/// @arg bounce
/// @arg rotate
/// @arg resource

function render_world_item(vbuffer, is3d, facecamera, bounce, rotate, res)
{
	if (!res_is_ready(res[0]))
		res[0] = mc_res
	
	if (!res_is_ready(res[1]))
		res[1] = mc_res
	
	if (!res_is_ready(res[2]))
		res[2] = mc_res
	
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
	
	if (res[0].item_sheet_texture != null)
		render_set_texture(res[0].item_sheet_texture)
	else
		render_set_texture(res[0].texture)
	
	if (res[1] != null && res[1] != mc_res)
	{
		if (shader_uniform_metallic != 0)
		{
			shader_uniform_metallic = 0
			render_set_uniform("uMetallic", shader_uniform_metallic)
		}
		
		if (shader_uniform_roughness != 0)
		{
			shader_uniform_roughness = 0
			render_set_uniform("uRoughness", shader_uniform_roughness)
		}
		
		if (shader_uniform_emissive != 0)
		{
			shader_uniform_emissive = 0
			render_set_uniform("uEmissive", shader_uniform_emissive)
		}
		
		if (res[1].item_sheet_texture_material != null)
			render_set_texture(res[1].item_sheet_texture_material, "Material")
		else
			render_set_texture(res[1].texture, "Material")
		
		render_set_uniform_int("uMaterialFormat", res[1].material_format)
	}
	else
	{
		render_set_texture(spr_default_material, "Material")
		render_set_uniform_int("uMaterialFormat", e_material.FORMAT_NONE)
	}
	
	if (res[2] != null && res[2] != mc_res)
	{
		if (res[2].item_sheet_tex_normal != null)
			render_set_texture(res[2].item_sheet_tex_normal, "Normal")
		else
			render_set_texture(res[2].texture, "Normal")
	}
	else
		render_set_texture(spr_default_normal, "Normal")
	
	vbuffer_render(vbuffer)
}
