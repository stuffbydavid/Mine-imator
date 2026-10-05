/// @arg vertexbuffer
/// @arg resource
/// @arg sheet
/// @arg is3d
/// @arg facecamera
/// @arg bounce
/// @arg rotate
/// @arg [realtime]

function render_world_item(vbuf, res, sheet, is3d, facecamera, bounce, rotate, realtime = false)
{
	for (var c = e_texture_channel.DIFFUSE; c < e_texture_channel.amount; c++)
		res[c] = res_eval(res[c])
	
	render_apply_res(res[e_texture_channel.DIFFUSE])
	if (facecamera || bounce || rotate)
		matrix_set(matrix_world, render_world_item_transform(matrix_get(matrix_world), facecamera, bounce, rotate, true, is3d, realtime))
	
	if (res[e_texture_channel.DIFFUSE].item_sheet_texture[sheet] != null)
		render_set_texture(res[e_texture_channel.DIFFUSE].item_sheet_texture[sheet])
	else
		render_set_texture(res[e_texture_channel.DIFFUSE].texture)
	
	if (res[e_texture_channel.MATERIAL] != null && res[e_texture_channel.MATERIAL] != mc_res)
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
		
		if (res[e_texture_channel.MATERIAL].item_sheet_texture_material[sheet] != null)
			render_set_texture(res[e_texture_channel.MATERIAL].item_sheet_texture_material[sheet], e_texture_channel.MATERIAL)
		else
			render_set_texture(res[e_texture_channel.MATERIAL].texture, e_texture_channel.MATERIAL)
		
		render_set_uniform_int(e_uniform.MATERIAL_FORMAT, res[e_texture_channel.MATERIAL].material_format)
	}
	else
	{
		render_set_texture(spr_default_material, e_texture_channel.MATERIAL)
		render_set_uniform_int(e_uniform.MATERIAL_FORMAT, e_material.FORMAT_NONE)
	}
	
	if (res[e_texture_channel.NORMAL] != null && res[e_texture_channel.NORMAL] != mc_res)
	{
		if (res[e_texture_channel.NORMAL].item_sheet_texture_normal[sheet] != null)
			render_set_texture(res[e_texture_channel.NORMAL].item_sheet_texture_normal[sheet], e_texture_channel.NORMAL)
		else
			render_set_texture(res[e_texture_channel.NORMAL].texture, e_texture_channel.NORMAL)
	}
	else
		render_set_texture(spr_default_normal, e_texture_channel.NORMAL)
	
	vbuffer_render(vbuf)
}
