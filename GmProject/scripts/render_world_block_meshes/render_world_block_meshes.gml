/// @desc Renders 64x64x64 block meshes with a shared texture and material state.
/// @arg object
/// @arg diffuse
/// @arg normal
/// @arg material

function render_world_block_meshes(obj, resdif, resnorm, resmat)
{
	if (array_length(obj.block_meshes) = 0)
		return 0

	resdif = res_eval(resdif)
	render_apply_res(resdif)

	var materials, hasmat, hasnorm;
	materials = (!render_fast_pass && render_material_pass)
	hasmat = false
	hasnorm = false
	
	if (materials)
	{
		resmat = res_eval(resmat)
		resnorm = res_eval(resnorm)
		hasmat = (resmat.type != e_res_type.PACK || resmat.pack_has_materials)
		hasnorm = (resnorm.type != e_res_type.PACK || resnorm.pack_has_normals)
	}

	var texlast, matlast, normlast, formatlast, colorlast, waterlast, vblast;
	var roughbase, metalbase, emissivebase, roughlast, metallast, emissivelast, frame, filterprev;
	texlast = null
	matlast = null
	normlast = null
	formatlast = null
	colorlast = null
	waterlast = null
	vblast = null
	roughlast = null
	metallast = null
	emissivelast = null
	roughbase = shader_uniform_roughness
	metalbase = shader_uniform_metallic
	emissivebase = shader_uniform_emissive
	frame = null
	filterprev = null

	// Keep opaque and transparent submissions in separate mip-filter passes
	for (var d = 0; d < e_block_depth.amount; d++)
	{
		if (render_world_blocks_transparent != null &&
			((d = e_block_depth.DEPTH0 && render_world_blocks_transparent = true) ||
			(d != e_block_depth.DEPTH0 && render_world_blocks_transparent = false)))
			continue

		if (d = e_block_depth.DEPTH1 && render_world_blocks_transparent = null &&
			!render_fast_pass && shader_texture_filter_mipmap && !app.project_render_transparent_block_texture_filtering)
		{
			filterprev = gpu_get_tex_mip_bias()
			gpu_set_tex_mip_bias(-16)
		}

		for (var s = 0; s < array_length(obj.block_meshes); s++)
		{
			var mesh = obj.block_meshes[s];
			if (mesh = null || !mesh.block_vbuffer_depth_active[@d])
				continue

			for (var vb = 0; vb < e_block_vbuffer.amount; vb++)
			{
				var index = d * e_block_vbuffer.amount + vb;
				if (!mesh.block_vbuffer_active[@index])
					continue

				var water, animated, tex, texmat, texnorm, matformat, col;
				water = (vb = e_block_vbuffer.WATER)
				if (water && render_fast_pass && render_depth_pass && render_mode != e_render_mode.DEPTH)
					continue

				if (vblast != vb)
				{
					var roughness, metallic, emissive, waterreflections;
					roughness = roughbase
					metallic = metalbase
					emissive = emissivebase
					waterreflections = water && app.project_render_water_reflections

					animated = (vb = e_block_vbuffer.ANIMATED || water)
					texmat = 0
					texnorm = 0
					col = shader_blend_color
					
					if (animated)
					{
						if (frame = null)
							frame = block_texture_get_frame()

						if (resdif.block_sheet_animated_diffuse)
							tex = resdif.block_sheet_texture[e_block_sheet.ANIMATED][frame]
						else
							tex = mc_res.block_sheet_texture[e_block_sheet.ANIMATED][frame]
						
						if (hasmat && resmat.block_sheet_animated_material)
							texmat = resmat.block_sheet_texture_material[e_block_sheet.ANIMATED][frame]
						
						if (hasnorm && resnorm.block_sheet_animated_normal)
							texnorm = resnorm.block_sheet_texture_normal[e_block_sheet.ANIMATED][frame]
						
						if (!hasmat || !resmat.block_sheet_animated_material)
						{
							roughness = 1
							metallic = 0
							emissive = 0
						}
					}
					else
					{
						var sheet = e_block_sheet.STATIC16;
						if (vb = e_block_vbuffer.STATIC32)
							sheet = e_block_sheet.STATIC32
						else if (vb = e_block_vbuffer.STATIC64)
							sheet = e_block_sheet.STATIC64

						tex = resdif.block_sheet_texture[sheet]
						
						if (tex = null)
							tex = mc_res.block_sheet_texture[sheet]
						
						if (hasmat)
							texmat = resmat.block_sheet_texture_material[sheet]
						
						if (hasnorm)
							texnorm = resnorm.block_sheet_texture_normal[sheet]
					}

					if (!render_fast_pass)
					{
						if (water)
						{
							col = color_multiply(col, resdif.color_list[@e_biome_color.WATER])
							
							if (waterreflections)
							{
								texmat = 0
								texnorm = 0
								roughness = app.project_render_water_roughness
								metallic = 0
								emissive = 0
							}
						}
						else if (vb >= e_block_vbuffer.GRASS && vb <= e_block_vbuffer.LEAVES_MANGROVE)
						{
							var colorindex = vb - e_block_vbuffer.GRASS;
							if (colorindex >= e_biome_color.WATER)
								colorindex++
							
							col = color_multiply(col, resdif.color_list[@colorindex])
						}

						if (texmat = null)
							texmat = 0
						
						if (texnorm = null)
							texnorm = 0
						
						matformat = texmat != 0 ? resmat.material_format : e_material.FORMAT_NONE
						if (formatlast != matformat)
						{
							render_set_uniform_int(e_uniform.MATERIAL_FORMAT, matformat)
							formatlast = matformat
						}
						
						if (matlast != texmat)
						{
							render_set_texture(resmat, texmat, e_texture_channel.MATERIAL)
							matlast = texmat
						}
						
						if (normlast != texnorm)
						{
							render_set_texture(resnorm, texnorm, e_texture_channel.NORMAL)
							normlast = texnorm
						}
						
						if (colorlast != col)
						{
							render_set_uniform_color(e_uniform.BLEND_COLOR, col, shader_blend_alpha)
							colorlast = col
						}
						
						if (waterlast != waterreflections)
						{
							render_set_uniform_int(e_uniform.IS_WATER, waterreflections)
							waterlast = waterreflections
						}
						
						if (roughlast != roughness)
						{
							render_set_uniform(e_uniform.ROUGHNESS, roughness)
							roughlast = roughness
						}

						if (metallast != metallic)
						{
							render_set_uniform(e_uniform.METALLIC, metallic)
							metallast = metallic
						}

						if (emissivelast != emissive)
						{
							render_set_uniform(e_uniform.EMISSIVE, emissive)
							emissivelast = emissive
						}
					}

					if (texlast != tex)
					{
						render_set_texture(resdif, tex)
						texlast = tex
					}
					
					vblast = vb
				}
				
				vbuffer_render(mesh.block_vbuffer[@index])
			}
		}
	}

	if (!render_fast_pass)
	{
		render_set_uniform_color(e_uniform.BLEND_COLOR, shader_blend_color, shader_blend_alpha)
		render_set_uniform_int(e_uniform.IS_WATER, 0)
		render_set_uniform(e_uniform.ROUGHNESS, roughbase)
		render_set_uniform(e_uniform.METALLIC, metalbase)
		render_set_uniform(e_uniform.EMISSIVE, emissivebase)
	}
	
	if (filterprev != null)
		gpu_set_tex_mip_bias(filterprev)
}
