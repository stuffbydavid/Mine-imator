/// render_world_item(vbuffer, resource, sheet, is3d, facecamera, bounce, rotate, [realtime])
/// @arg vbuffer
/// @arg resource
/// @arg sheet
/// @arg is3d
/// @arg facecamera
/// @arg bounce
/// @arg rotate
/// @arg [realtime]

function render_world_item(vbuffer, res, sheet, is3d, facecamera, bounce, rotate, realtime = false)
{
	if (!res_is_ready(res[e_texture_channel.DIFFUSE]))
		res[e_texture_channel.DIFFUSE] = mc_res
	
	if (!res_is_ready(res[e_texture_channel.NORMAL]))
		res[e_texture_channel.NORMAL] = mc_res
	
	if (!res_is_ready(res[e_texture_channel.MATERIAL]))
		res[e_texture_channel.MATERIAL] = mc_res
	
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
		t = (realtime ? current_step : app.background_time) mod d * 360
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
		t = (realtime ? current_step : app.background_time) mod d * 2
		if (t < d)
			offz = ease("easeinoutquad", t / d) * 2 - 1
		else
			offz = 1 - ease("easeinoutquad", (t - d) / d) * 2
		matrix_world_multiply_post(matrix_build(0, 0, offz, 0, 0, 0, 1, 1, 1))
	}
	
	if (res[e_texture_channel.DIFFUSE].item_sheet_texture[sheet] != null)
		render_set_texture(res[e_texture_channel.DIFFUSE].item_sheet_texture[sheet])
	else
		render_set_texture(res[e_texture_channel.DIFFUSE].texture)
	
	if (res[e_texture_channel.MATERIAL] != null && res[e_texture_channel.MATERIAL] != mc_res)
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
		
		if (res[e_texture_channel.MATERIAL].item_sheet_texture_material[sheet] != null)
			render_set_texture(res[e_texture_channel.MATERIAL].item_sheet_texture_material[sheet], "Material")
		else
			render_set_texture(res[e_texture_channel.MATERIAL].texture, "Material")
		
		render_set_uniform_int("uMaterialFormat", res[e_texture_channel.MATERIAL].material_format)
	}
	else
	{
		render_set_texture(spr_default_material, "Material")
		render_set_uniform_int("uMaterialFormat", e_material.FORMAT_NONE)
	}
	
	if (res[e_texture_channel.NORMAL] != null && res[e_texture_channel.NORMAL] != mc_res)
	{
		if (res[e_texture_channel.NORMAL].item_sheet_texture_normal[sheet] != null)
			render_set_texture(res[e_texture_channel.NORMAL].item_sheet_texture_normal[sheet], "Normal")
		else
			render_set_texture(res[e_texture_channel.NORMAL].texture, "Normal")
	}
	else
		render_set_texture(spr_default_normal, "Normal")
	
	vbuffer_render(vbuffer)
}
