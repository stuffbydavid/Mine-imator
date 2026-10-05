/// @arg vertexbuffer
/// @arg diffuse
/// @arg normal
/// @arg material
/// @arg sheet
/// @arg is3d
/// @arg facecamera
/// @arg bounce
/// @arg rotate
/// @arg [realtime]

function render_world_item(vbuf, resdif, resnorm, resmat, sheet, is3d, facecamera, bounce, rotate, realtime = false)
{
	if (render_depth_pass)
		return render_world_item_depth(vbuf, resdif, sheet, is3d, facecamera, bounce, rotate, realtime)
	
	resdif = res_eval(resdif)
	resnorm = res_eval(resnorm)
	resmat = res_eval(resmat)
	
	render_apply_res(resdif)
	if (facecamera || bounce || rotate)
		matrix_set(matrix_world, render_world_item_transform(matrix_get(matrix_world), facecamera, bounce, rotate, true, is3d, realtime))
	
	if (resdif.item_sheet_texture[sheet] != null)
		render_set_texture(resdif.item_sheet_texture[sheet])
	else
		render_set_texture(resdif.texture)
	
	if (resmat != null && resmat != mc_res)
	{
		if (shader_uniform_metallic != 0)
		{
			shader_uniform_metallic = 0
			render_set_uniform(e_uniform.METALLIC, shader_uniform_metallic)
		}
		
		if (shader_uniform_roughness != 0)
		{
			shader_uniform_roughness = 0
			render_set_uniform(e_uniform.ROUGHNESS, shader_uniform_roughness)
		}
		
		if (shader_uniform_emissive != 0)
		{
			shader_uniform_emissive = 0
			render_set_uniform(e_uniform.EMISSIVE, shader_uniform_emissive)
		}
		
		if (resmat.item_sheet_texture_material[sheet] != null)
			render_set_texture(resmat.item_sheet_texture_material[sheet], e_texture_channel.MATERIAL)
		else
			render_set_texture(resmat.texture, e_texture_channel.MATERIAL)
		
		render_set_uniform_int(e_uniform.MATERIAL_FORMAT, resmat.material_format)
	}
	else
	{
		render_set_texture(spr_default_material, e_texture_channel.MATERIAL)
		render_set_uniform_int(e_uniform.MATERIAL_FORMAT, e_material.FORMAT_NONE)
	}
	
	if (resnorm != null && resnorm != mc_res)
	{
		if (resnorm.item_sheet_texture_normal[sheet] != null)
			render_set_texture(resnorm.item_sheet_texture_normal[sheet], e_texture_channel.NORMAL)
		else
			render_set_texture(resnorm.texture, e_texture_channel.NORMAL)
	}
	else
		render_set_texture(spr_default_normal, e_texture_channel.NORMAL)
	
	vbuffer_render(vbuf)
}
