/// @arg block
/// @arg diffuse
/// @arg normal
/// @arg material
/// @arg [rotate]
/// @arg [size]
/// @arg [template]

function render_world_block(block, resdif, resnorm, resmat, rotate = false, size = undefined, temp = null)
{
	if (render_depth_pass)
		return render_world_block_depth(block, resdif, rotate, size)
	
	var vbuffer = block.block_vbuffer;
	if (vbuffer = null)
		return 0
	
	resdif = res_eval(resdif)
	resnorm = res_eval(resnorm)
	resmat = res_eval(resmat)
	
	var tex, texprev, texani;
	var texmat, texmatprev, texanimat, texanimatsheet;
	var texnormal, texnormalprev, texaninormal;
	var hasmat, hasnorm, materialformat;
	
	render_apply_res(resdif)
	
	hasmat = (resmat.type != e_res_type.PACK || resmat.pack_has_materials)
	hasnorm = (resnorm.type != e_res_type.PACK || resnorm.pack_has_normals)
	
	tex = resdif.block_sheet_texture[e_block_sheet.STATIC16]
	texmat = hasmat ? resmat.block_sheet_texture_material[e_block_sheet.STATIC16] : 0
	texnormal = hasnorm ? resnorm.block_sheet_texture_normal[e_block_sheet.STATIC16] : 0
	
	if (texmat = null)
		texmat = 0
	
	if (texnormal = null)
		texnormal = 0
	
	materialformat = texmat != 0 ? resmat.material_format : e_material.FORMAT_NONE
	
	render_set_uniform_int(e_uniform.MATERIAL_FORMAT, materialformat)
	
	texprev = tex
	texmatprev = texmat
	texnormalprev = texnormal
	
	if (resdif.block_sheet_texture[e_block_sheet.ANIMATED] != null)
		texani = resdif.block_sheet_texture[e_block_sheet.ANIMATED][block_texture_get_frame()]
	else
		texani = mc_res.block_sheet_texture[e_block_sheet.ANIMATED][block_texture_get_frame()]
	
	texanimatsheet = (!hasmat || resmat.block_sheet_texture_material[e_block_sheet.ANIMATED] = null)
	
	if (!texanimatsheet)
		texanimat = resmat.block_sheet_texture_material[e_block_sheet.ANIMATED][block_texture_get_frame()]
	else
		texanimat = 0
	
	if (hasnorm && resnorm.block_sheet_texture_normal[e_block_sheet.ANIMATED] != null)
		texaninormal = resnorm.block_sheet_texture_normal[e_block_sheet.ANIMATED][block_texture_get_frame()]
	else
		texaninormal = 0
	
	var blend = shader_blend_color;
	render_set_texture(tex)
	render_set_texture(texmat, e_texture_channel.MATERIAL)
	render_set_texture(texnormal, e_texture_channel.NORMAL)
	
	// Rotate by 90 degrees for legacy support
	if (rotate)
		matrix_world_multiply_pre(matrix_create(point3D(0, size[Y] * block_size, 0), vec3(0, 0, 90), vec3(1)))
	
	#region Depth 0
	
	if (render_world_block_transparent != true)
	{
		if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.STATIC16]))
			vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.STATIC16])

		// High-resolution sheets
		var materialformatprev = materialformat;
		for (var s = e_block_sheet.STATIC32; s < e_block_sheet.static_amount; s++)
		{
			var staticvbuffer = e_block_vbuffer.STATIC32 + s - e_block_sheet.STATIC32;
			if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, staticvbuffer]))
			{
				var statictex, statictexmat, statictexnormal, staticmaterialformat;
				statictex = resdif.block_sheet_texture[s]
				statictexmat = hasmat ? resmat.block_sheet_texture_material[s] : 0
				statictexnormal = hasnorm ? resnorm.block_sheet_texture_normal[s] : 0
				staticmaterialformat = statictexmat != null && statictexmat != 0 ? resmat.material_format : e_material.FORMAT_NONE

				if (statictex = null)
					statictex = mc_res.block_sheet_texture[s]
				
				if (statictexmat = null)
					statictexmat = 0
				
				if (statictexnormal = null)
					statictexnormal = 0

				if (staticmaterialformat != materialformatprev)
				{
					render_set_uniform_int(e_uniform.MATERIAL_FORMAT, staticmaterialformat)
					materialformatprev = staticmaterialformat
				}

				if (statictex != texprev)
				{
					render_set_texture(statictex)
					texprev = statictex
				}

				if (statictexmat != texmatprev)
				{
					render_set_texture(statictexmat, e_texture_channel.MATERIAL)
					texmatprev = statictexmat
				}

				if (statictexnormal != texnormalprev)
				{
					render_set_texture(statictexnormal, e_texture_channel.NORMAL)
					texnormalprev = statictexnormal
				}

				vbuffer_render(vbuffer[e_block_depth.DEPTH0, staticvbuffer])
			}
		}
		if (materialformatprev != materialformat)
			render_set_uniform_int(e_uniform.MATERIAL_FORMAT, materialformat)
	
		if (tex != texprev)
		{
			render_set_texture(tex)
			texprev = tex
		}

		if (texmat != texmatprev)
		{
			render_set_texture(texmat, e_texture_channel.MATERIAL)
			texmatprev = texmat
		}

		if (texnormal != texnormalprev)
		{
			render_set_texture(texnormal, e_texture_channel.NORMAL)
			texnormalprev = texnormal
		}

		// Grass
		if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.GRASS]))
		{
			render_set_uniform_color(e_uniform.BLEND_COLOR, color_multiply(blend, resdif.color_list[@ e_biome_color.GRASS]), shader_blend_alpha)
			vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.GRASS])
			render_set_uniform_color(e_uniform.BLEND_COLOR, blend, shader_blend_alpha)
		}
	
		// Foliage
		if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.FOLIAGE]))
		{
			render_set_uniform_color(e_uniform.BLEND_COLOR, color_multiply(blend, resdif.color_list[@ e_biome_color.FOLIAGE]), shader_blend_alpha)
			vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.FOLIAGE])
			render_set_uniform_color(e_uniform.BLEND_COLOR, blend, shader_blend_alpha)
		}
	
		// Dry foliage
		if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.DRY_FOLIAGE]))
		{
			render_set_uniform_color(e_uniform.BLEND_COLOR, color_multiply(blend, resdif.color_list[@ e_biome_color.DRY_FOLIAGE]), shader_blend_alpha)
			vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.DRY_FOLIAGE])
			render_set_uniform_color(e_uniform.BLEND_COLOR, blend, shader_blend_alpha)
		}
	
		if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.ANIMATED]))
		{
			if (texani != texprev)
			{
				render_set_texture(texani)
				texprev = texani
			}
		
			if (texanimat != texmatprev)
			{
				render_set_texture(texanimat, e_texture_channel.MATERIAL)
				texmatprev = texanimat
			}
		
			if (texaninormal != texnormalprev)
			{
				render_set_texture(texaninormal, e_texture_channel.NORMAL)
				texnormalprev = texaninormal
			}
		
			if (texanimatsheet)
				render_set_material_none()
		
			vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.ANIMATED])	
			if (texanimatsheet)
				render_set_uniform_int(e_uniform.MATERIAL_FORMAT, materialformat)
		}
	}
	
	#endregion
	
	#region Depth 1
	
	if (render_world_block_transparent != null && !render_world_block_transparent)
		return 0
	
	var filterprev = null;
	if (render_world_block_transparent = null && shader_texture_filter_mipmap && !app.project_render_transparent_block_texture_filtering)
	{
		filterprev = gpu_get_tex_mip_bias()
		gpu_set_tex_mip_bias(-16)
	}
	
	if (tex != texprev)
	{
		render_set_texture(tex)
		texprev = tex
	}
	
	if (texmat != texmatprev)
	{
		render_set_texture(texmat, e_texture_channel.MATERIAL)
		texmatprev = texmat
	}
	
	if (texnormal != texnormalprev)
	{
		render_set_texture(texnormal, e_texture_channel.NORMAL)
		texnormalprev = texnormal
	}
	
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.STATIC16]))
		vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.STATIC16])
		
	for (var vbuf = e_block_vbuffer.GRASS; vbuf <= e_block_vbuffer.LEAVES_MANGROVE; vbuf++)
	{
		if (vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, vbuf]))
			continue
		
		var colorindex = vbuf - e_block_vbuffer.GRASS;
		if (colorindex >= e_biome_color.WATER)
			colorindex++
		
		render_set_uniform_color(e_uniform.BLEND_COLOR, color_multiply(blend, resdif.color_list[@ colorindex]), shader_blend_alpha)
		vbuffer_render(vbuffer[e_block_depth.DEPTH1, vbuf])
	}
	
	render_set_uniform_color(e_uniform.BLEND_COLOR, blend, shader_blend_alpha)
	
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.ANIMATED]))
	{
		if (texani != texprev)
		{
			render_set_texture(texani)
			texprev = texani
		}
		
		if (texanimat != texmatprev)
		{
			render_set_texture(texanimat, e_texture_channel.MATERIAL)
			texmatprev = texanimat
		}
		
		if (texaninormal != texnormalprev)
		{
			render_set_texture(texaninormal, e_texture_channel.NORMAL)
			texnormalprev = texaninormal
		}
		
		if (texanimatsheet)
			render_set_material_none()
		
		vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.ANIMATED])
		if (texanimatsheet)
			render_set_uniform_int(e_uniform.MATERIAL_FORMAT, materialformat)
	}
	
	if (tex != texprev)
	{
		render_set_texture(tex)
		texprev = tex
	}
	
	if (texmat != texmatprev)
	{
		render_set_texture(texmat, e_texture_channel.MATERIAL)
		texmatprev = texmat
	}
	
	if (texnormal != texnormalprev)
	{
		render_set_texture(texnormal, e_texture_channel.NORMAL)
		texnormalprev = texnormal
	}
	
	#endregion
	
	#region Depth 2
	
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.STATIC16]))
		vbuffer_render(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.STATIC16])
	
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.ANIMATED]))
	{
		render_set_texture(texani)
		render_set_texture(texanimat, e_texture_channel.MATERIAL)
		render_set_texture(texaninormal, e_texture_channel.NORMAL)
		
		if (texanimatsheet)
			render_set_material_none()
		
		vbuffer_render(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.ANIMATED])
		if (texanimatsheet)
			render_set_uniform_int(e_uniform.MATERIAL_FORMAT, materialformat)
	}
	
	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.WATER]))
	{
		if (render_mode != e_render_mode.HIGH_LIGHT_SUN_DEPTH && 
			render_mode != e_render_mode.HIGH_LIGHT_SPOT_DEPTH && 
			render_mode != e_render_mode.HIGH_LIGHT_POINT_DEPTH)
		{
			render_set_texture(texani)
			render_set_uniform_color(e_uniform.BLEND_COLOR, color_multiply(blend, resdif.color_list[@ e_biome_color.WATER]), shader_blend_alpha)
			render_set_uniform_int(e_uniform.IS_WATER, app.project_render_water_reflections)
			
			if (app.project_render_water_reflections) // Default water reflections provided by MI
			{
				render_set_material_textures_none()
				
				if (shader_uniform_roughness != app.project_render_water_roughness)
				{
					shader_uniform_roughness = app.project_render_water_roughness
					render_set_uniform(e_uniform.ROUGHNESS, shader_uniform_roughness)
				}
				
				if (shader_uniform_metallic != 0)
				{
					shader_uniform_metallic = 0
					render_set_uniform(e_uniform.METALLIC, shader_uniform_metallic)
				}
				
				if (shader_uniform_emissive != 0)
				{
					shader_uniform_emissive = 0
					render_set_uniform(e_uniform.EMISSIVE, shader_uniform_emissive)
				}
			}
			else
			{
				render_set_texture(texanimat, e_texture_channel.MATERIAL)
				render_set_texture(texaninormal, e_texture_channel.NORMAL)
			}
			
			vbuffer_render(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.WATER])
			
			render_set_uniform_color(e_uniform.BLEND_COLOR, blend, shader_blend_alpha)
			render_set_uniform_int(e_uniform.IS_WATER, 0)
		}
	}
	
	if (filterprev != null)
		gpu_set_tex_mip_bias(filterprev)
	
	#endregion
}
