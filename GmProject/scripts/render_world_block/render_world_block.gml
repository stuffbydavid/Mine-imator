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
	
	if (block.block_vbuffer = null)
		return 0
	
	resdif = res_eval(resdif)
	resnorm = res_eval(resnorm)
	resmat = res_eval(resmat)
	
	var tex, texprev, texani;
	var texmat, texmatprev, texanimat, texanimatsheet;
	var texnorm, texnormprev, texaninorm;
	var hasmat, hasnorm, matformat;
	var active0, active1, active2, animactive, frame, texready, blend, basebound;
	
	render_apply_res(resdif)
	
	tex = resdif.block_sheet_texture[e_block_sheet.STATIC16]
	
	// Material pass
	if (render_material_pass)
	{
		hasmat = (resmat.type != e_res_type.PACK || resmat.pack_has_materials)
		hasnorm = (resnorm.type != e_res_type.PACK || resnorm.pack_has_normals)
		
		texmat = hasmat ? resmat.block_sheet_texture_material[e_block_sheet.STATIC16] : 0
		texnorm = hasnorm ? resnorm.block_sheet_texture_normal[e_block_sheet.STATIC16] : 0
		
		if (texmat = null)
			texmat = 0
	
		if (texnorm = null)
			texnorm = 0
		
		matformat = texmat != 0 ? resmat.material_format : e_material.FORMAT_NONE
	}
	else
	{
		hasmat = false
		hasnorm = false
		texmat = 0
		texnorm = 0
		matformat = e_material.FORMAT_NONE
	}
	
	render_set_uniform_int(e_uniform.MATERIAL_FORMAT, matformat)
	
	texprev = tex
	texmatprev = texmat
	texnormprev = texnorm
	texready = false

	active0 = e_block_depth.DEPTH0 * e_block_vbuffer.amount
	active1 = e_block_depth.DEPTH1 * e_block_vbuffer.amount
	active2 = e_block_depth.DEPTH2 * e_block_vbuffer.amount
	
	animactive = (
		block.block_vbuffer_active[@ active0 + e_block_vbuffer.ANIMATED] ||
		block.block_vbuffer_active[@ active1 + e_block_vbuffer.ANIMATED] ||
		block.block_vbuffer_active[@ active2 + e_block_vbuffer.ANIMATED] ||
		block.block_vbuffer_active[@ active2 + e_block_vbuffer.WATER]
	)
	
	if (animactive)
	{
		frame = block_texture_get_frame()
		texani = resdif.block_sheet_animated_diffuse ? resdif.block_sheet_texture[e_block_sheet.ANIMATED][frame] : mc_res.block_sheet_texture[e_block_sheet.ANIMATED][frame]
		texanimatsheet = !hasmat || !resmat.block_sheet_animated_material
		texanimat = texanimatsheet ? 0 : resmat.block_sheet_texture_material[e_block_sheet.ANIMATED][frame]
		texaninorm = hasnorm && resnorm.block_sheet_animated_normal ? resnorm.block_sheet_texture_normal[e_block_sheet.ANIMATED][frame] : 0
	}
	
	blend = shader_blend_color
	
	// Rotate by 90 degrees for legacy support
	if (rotate)
		matrix_world_multiply_pre(render_world_block_transform(size[Y]))
	
	#region Depth 0
	
	if (render_world_block_transparent != true)
	{
		if (block.block_vbuffer_active[@ active0 + e_block_vbuffer.STATIC16])
		{
			render_set_texture(resdif, tex)
			render_set_texture(resmat, texmat, e_texture_channel.MATERIAL)
			render_set_texture(resnorm, texnorm, e_texture_channel.NORMAL)
			
			texready = true
			vbuffer_render(block.block_vbuffer[@ active0 + e_block_vbuffer.STATIC16])
		}

		// High-resolution sheets
		var materialformatprev = matformat;
		for (var s = e_block_sheet.STATIC32; s < e_block_sheet.static_amount; s++)
		{
			var staticvbuf = e_block_vbuffer.STATIC32 + s - e_block_sheet.STATIC32;
			if (block.block_vbuffer_active[@ active0 + staticvbuf])
			{
				var statictex, statictexmat, statictexnorm, staticmatformat;
				statictex = resdif.block_sheet_texture[s]
				statictexmat = hasmat ? resmat.block_sheet_texture_material[s] : 0
				statictexnorm = hasnorm ? resnorm.block_sheet_texture_normal[s] : 0
				staticmatformat = statictexmat != null && statictexmat != 0 ? resmat.material_format : e_material.FORMAT_NONE

				if (statictex = null)
					statictex = mc_res.block_sheet_texture[s]
				
				if (statictexmat = null)
					statictexmat = 0
				
				if (statictexnorm = null)
					statictexnorm = 0

				if (staticmatformat != materialformatprev)
				{
					render_set_uniform_int(e_uniform.MATERIAL_FORMAT, staticmatformat)
					materialformatprev = staticmatformat
				}

				if (!texready || statictex != texprev)
				{
					render_set_texture(resdif, statictex)
					texprev = statictex
				}

				if (!texready || statictexmat != texmatprev)
				{
					render_set_texture(resmat, statictexmat, e_texture_channel.MATERIAL)
					texmatprev = statictexmat
				}

				if (!texready || statictexnorm != texnormprev)
				{
					render_set_texture(resnorm, statictexnorm, e_texture_channel.NORMAL)
					texnormprev = statictexnorm
				}

				texready = true
				vbuffer_render(block.block_vbuffer[@ active0 + staticvbuf])
			}
		}
		if (materialformatprev != matformat)
			render_set_uniform_int(e_uniform.MATERIAL_FORMAT, matformat)
	
		if (block.block_vbuffer_active[@ active0 + e_block_vbuffer.GRASS] ||
			block.block_vbuffer_active[@ active0 + e_block_vbuffer.FOLIAGE] ||
			block.block_vbuffer_active[@ active0 + e_block_vbuffer.DRY_FOLIAGE])
		{
			if (!texready || tex != texprev)
			{
				render_set_texture(resdif, tex)
				texprev = tex
			}
			
			if (!texready || texmat != texmatprev)
			{
				render_set_texture(resmat, texmat, e_texture_channel.MATERIAL)
				texmatprev = texmat
			}
			
			if (!texready || texnorm != texnormprev)
			{
				render_set_texture(resnorm, texnorm, e_texture_channel.NORMAL)
				texnormprev = texnorm
			}
			
			texready = true
		}

		// Biome colors
		for (var colorbuf = e_block_vbuffer.GRASS; colorbuf <= e_block_vbuffer.DRY_FOLIAGE; colorbuf++)
		{
			if (!block.block_vbuffer_active[@ active0 + colorbuf])
				continue
			
			render_set_uniform_color(e_uniform.BLEND_COLOR, color_multiply(blend, resdif.color_list[@ e_biome_color.GRASS + colorbuf - e_block_vbuffer.GRASS]), shader_blend_alpha)
			vbuffer_render(block.block_vbuffer[@ active0 + colorbuf])
			render_set_uniform_color(e_uniform.BLEND_COLOR, blend, shader_blend_alpha)
		}
	
		if (block.block_vbuffer_active[@ active0 + e_block_vbuffer.ANIMATED])
		{
			if (!texready || texani != texprev)
			{
				render_set_texture(resdif, texani)
				texprev = texani
			}
		
			if (!texready || texanimat != texmatprev)
			{
				render_set_texture(resmat, texanimat, e_texture_channel.MATERIAL)
				texmatprev = texanimat
			}
		
			if (!texready || texaninorm != texnormprev)
			{
				render_set_texture(resnorm, texaninorm, e_texture_channel.NORMAL)
				texnormprev = texaninorm
			}
		
			texready = true
			if (texanimatsheet)
				render_set_material_none()
		
			vbuffer_render(block.block_vbuffer[@ active0 + e_block_vbuffer.ANIMATED])
			
			if (texanimatsheet)
				render_set_uniform_int(e_uniform.MATERIAL_FORMAT, matformat)
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
	
	if (block.block_vbuffer_active[@ active1 + e_block_vbuffer.STATIC16])
	{
		if (!texready || tex != texprev)
		{
			render_set_texture(resdif, tex)
			texprev = tex
		}
		
		if (!texready || texmat != texmatprev)
		{
			render_set_texture(resmat, texmat, e_texture_channel.MATERIAL)
			texmatprev = texmat
		}
		
		if (!texready || texnorm != texnormprev)
		{
			render_set_texture(resnorm, texnorm, e_texture_channel.NORMAL)
			texnormprev = texnorm
		}
		
		texready = true
		vbuffer_render(block.block_vbuffer[@ active1 + e_block_vbuffer.STATIC16])
	}
		
	basebound = false
	for (var vbuf = e_block_vbuffer.GRASS; vbuf <= e_block_vbuffer.LEAVES_MANGROVE; vbuf++)
	{
		if (!block.block_vbuffer_active[@ active1 + vbuf])
			continue
		if (!basebound)
		{
			if (!texready || tex != texprev)
			{
				render_set_texture(resdif, tex)
				texprev = tex
			}
			
			if (!texready || texmat != texmatprev)
			{
				render_set_texture(resmat, texmat, e_texture_channel.MATERIAL)
				texmatprev = texmat
			}
			
			if (!texready || texnorm != texnormprev)
			{
				render_set_texture(resnorm, texnorm, e_texture_channel.NORMAL)
				texnormprev = texnorm
			}
			
			texready = true
			basebound = true
		}
		
		var colorindex = vbuf - e_block_vbuffer.GRASS;
		if (colorindex >= e_biome_color.WATER)
			colorindex++
		
		render_set_uniform_color(e_uniform.BLEND_COLOR, color_multiply(blend, resdif.color_list[@ colorindex]), shader_blend_alpha)
		vbuffer_render(block.block_vbuffer[@ active1 + vbuf])
	}
	
	render_set_uniform_color(e_uniform.BLEND_COLOR, blend, shader_blend_alpha)
	
	if (block.block_vbuffer_active[@ active1 + e_block_vbuffer.ANIMATED])
	{
		if (!texready || texani != texprev)
		{
			render_set_texture(resdif, texani)
			texprev = texani
		}
		
		if (!texready || texanimat != texmatprev)
		{
			render_set_texture(resmat, texanimat, e_texture_channel.MATERIAL)
			texmatprev = texanimat
		}
		
		if (!texready || texaninorm != texnormprev)
		{
			render_set_texture(resnorm, texaninorm, e_texture_channel.NORMAL)
			texnormprev = texaninorm
		}
		
		texready = true
		if (texanimatsheet)
			render_set_material_none()
		
		vbuffer_render(block.block_vbuffer[@ active1 + e_block_vbuffer.ANIMATED])
		
		if (texanimatsheet)
			render_set_uniform_int(e_uniform.MATERIAL_FORMAT, matformat)
	}
	
	#endregion
	
	#region Depth 2
	
	if (block.block_vbuffer_active[@ active2 + e_block_vbuffer.STATIC16])
	{
		if (!texready || tex != texprev)
		{
			render_set_texture(resdif, tex)
			texprev = tex
		}
		
		if (!texready || texmat != texmatprev)
		{
			render_set_texture(resmat, texmat, e_texture_channel.MATERIAL)
			texmatprev = texmat
		}
		
		if (!texready || texnorm != texnormprev)
		{
			render_set_texture(resnorm, texnorm, e_texture_channel.NORMAL)
			texnormprev = texnorm
		}
		
		texready = true
		vbuffer_render(block.block_vbuffer[@ active2 + e_block_vbuffer.STATIC16])
	}
	
	if (block.block_vbuffer_active[@ active2 + e_block_vbuffer.ANIMATED])
	{
		render_set_texture(resdif, texani)
		render_set_texture(resmat, texanimat, e_texture_channel.MATERIAL)
		render_set_texture(resnorm, texaninorm, e_texture_channel.NORMAL)
		
		if (texanimatsheet)
			render_set_material_none()
		
		vbuffer_render(block.block_vbuffer[@ active2 + e_block_vbuffer.ANIMATED])
		
		if (texanimatsheet)
			render_set_uniform_int(e_uniform.MATERIAL_FORMAT, matformat)
	}
	
	if (block.block_vbuffer_active[@ active2 + e_block_vbuffer.WATER])
	{
		if (render_mode != e_render_mode.HIGH_LIGHT_SUN_DEPTH && 
			render_mode != e_render_mode.HIGH_LIGHT_SPOT_DEPTH && 
			render_mode != e_render_mode.HIGH_LIGHT_POINT_DEPTH)
		{
			render_set_texture(resdif, texani)
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
				render_set_texture(resmat, texanimat, e_texture_channel.MATERIAL)
				render_set_texture(resnorm, texaninorm, e_texture_channel.NORMAL)
			}
			
			vbuffer_render(block.block_vbuffer[@ active2 + e_block_vbuffer.WATER])
			
			render_set_uniform_color(e_uniform.BLEND_COLOR, blend, shader_blend_alpha)
			render_set_uniform_int(e_uniform.IS_WATER, 0)
		}
	}
	
	if (filterprev != null)
		gpu_set_tex_mip_bias(filterprev)
	
	#endregion
}
