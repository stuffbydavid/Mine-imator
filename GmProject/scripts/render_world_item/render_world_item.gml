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
	var texmat, texnorm;
	
	resdif = res_eval(resdif)
	resnorm = res_eval(resnorm)
	resmat = res_eval(resmat)
	texmat = (resmat.type = e_res_type.PACK && !resmat.pack_has_materials) ? 0 : resmat.item_sheet_texture_material[sheet]
	texnorm = (resnorm.type = e_res_type.PACK && !resnorm.pack_has_normals) ? 0 : resnorm.item_sheet_texture_normal[sheet]
	
	if (texmat = null && resmat.type != e_res_type.PACK)
		texmat = resmat.texture
	
	if (texnorm = null && resnorm.type != e_res_type.PACK)
		texnorm = resnorm.texture
	
	render_apply_res(resdif)
	
	if (facecamera || bounce || rotate)
		matrix_set(matrix_world, render_world_item_transform(matrix_get(matrix_world), facecamera, bounce, rotate, true, is3d, realtime))
	
	if (resdif.item_sheet_texture[sheet] != null)
		render_set_texture(resdif.item_sheet_texture[sheet])
	else
		render_set_texture(resdif.texture)
	
	if (texmat != null && texmat != 0)
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
		
		render_set_texture(texmat, e_texture_channel.MATERIAL)
		
		render_set_uniform_int(e_uniform.MATERIAL_FORMAT, resmat.material_format)
	}
	else
	{
		render_set_texture(0, e_texture_channel.MATERIAL)
		render_set_uniform_int(e_uniform.MATERIAL_FORMAT, e_material.FORMAT_NONE)
	}
	
	render_set_texture(texnorm, e_texture_channel.NORMAL)
	
	vbuffer_render(vbuf)
}
