/// @desc Renders 64x64x64 block meshes with a shared texture and material state.
/// @arg object
/// @arg diffuse
/// @arg normal
/// @arg material
/// @arg [meshoffset]
/// @arg [meshcount]

function render_world_block_meshes(obj, resdif, resnorm, resmat, meshoffset = 0, meshcount = null)
{
	if (array_length(obj.block_meshes) = 0)
		return 0

	resdif = res_eval(resdif)
	render_apply_res(resdif)

	// Submit color palette
	var colorres = (resdif.type = e_res_type.PACK ? resdif : mc_res);
	render_set_uniform(e_uniform.BLOCK_COLORS, render_fast_pass ? colorres.block_colors_fast : colorres.block_colors)

	var hasmat, hasnorm;
	hasmat = false
	hasnorm = false

	if (!render_fast_pass && render_material_pass)
	{
		resmat = res_eval(resmat)
		resnorm = res_eval(resnorm)
		hasmat = (resmat.type != e_res_type.PACK || resmat.pack_has_materials)
		hasnorm = (resnorm.type != e_res_type.PACK || resnorm.pack_has_normals)
	}

	// Cache submissions across all meshes using the same resources
	var texlast, matlast, normlast, formatlast, colorlast, waterlast;
	var roughlast, metallast, emissivelast, framelast, vbufprev, filterprev, meshend, mesheditcount;
	texlast = null
	matlast = null
	normlast = null
	formatlast = null
	colorlast = null
	waterlast = null
	roughlast = null
	metallast = null
	emissivelast = null
	framelast = null
	vbufprev = null
	filterprev = null
	
	meshend = array_length(obj.block_meshes)
	if (meshcount != null)
		meshend = min(meshend, meshoffset + meshcount)
	
	if (obj.object_index = obj_timeline)
		mesheditcount = array_length(obj.block_meshes_edit)
	else
		mesheditcount = 0
	
	// Keep opaque and transparent submissions in separate mip-filter passes
	for (var d = 0; d < e_block_depth.amount; d++)
	{
		if (render_world_blocks_transparent != null &&
			((d = e_block_depth.DEPTH0 && render_world_blocks_transparent = true) ||
			(d != e_block_depth.DEPTH0 && render_world_blocks_transparent = false)))
			continue

		// Disable texture filtering for transparent blocks
		if (d = e_block_depth.DEPTH1 && render_world_blocks_transparent = null &&
			!render_fast_pass && shader_texture_filter_mipmap && !app.project_render_transparent_block_texture_filtering)
		{
			filterprev = gpu_get_tex_mip_bias()
			gpu_set_tex_mip_bias(-16)
		}

		for (var s = meshoffset; s < meshend; s++)
		{
			var source, mesh;
			source = obj.block_meshes[s]
			mesh = null
			
			// Edited meshes cache the render order of both source and override buffers
			if (s < mesheditcount)
				mesh = obj.block_meshes_edit[s]
			
			if (mesh = null)
				mesh = source
				
			if (mesh = null)
				continue

			with (mesh)
			{
				// Visit only populated buffers, preserving mesh order within each pass
				var first, last;
				first = block_vbuffer_render_offsets[@d]
				last = block_vbuffer_render_offsets[@d + 1]

				for (var i = first; i < last; i++)
				{
					var index, vb, water;
					index = block_vbuffer_render_order[@i]
					vb = index mod e_block_vbuffer.amount
					water = (vb = e_block_vbuffer.WATER)
					
					if (water && render_fast_pass && render_depth_pass && render_mode != e_render_mode.DEPTH)
						continue

					if (vbufprev != vb)
					{
						var tex, texmat, texnorm, col, roughness, metallic, emissive, waterreflections;
						texmat = 0
						texnorm = 0
						col = shader_blend_color
						roughness = shader_uniform_roughness
						metallic = shader_uniform_metallic
						emissive = shader_uniform_emissive
						waterreflections = (water && app.project_render_water_reflections)

						if (vb = e_block_vbuffer.ANIMATED || water)
						{
							if (framelast = null)
								framelast = block_texture_get_frame()

							var frame = framelast;

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

							if (texmat = null)
								texmat = 0

							if (texnorm = null)
								texnorm = 0

							var matformat = texmat != 0 ? resmat.material_format : e_material.FORMAT_NONE;
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
						
						vbufprev = vb
					}

					var vbuf = block_vbuffer[@index];
					
					if (vbuf = null && source != null)
						vbuf = source.block_vbuffer[@index]
					
					vertex_submit(vbuf, pr_trianglelist, -1)
				}
			}
		}
	}

	if (!render_fast_pass)
	{
		render_set_uniform_color(e_uniform.BLEND_COLOR, shader_blend_color, shader_blend_alpha)
		render_set_uniform_int(e_uniform.IS_WATER, 0)
		render_set_uniform(e_uniform.ROUGHNESS, shader_uniform_roughness)
		render_set_uniform(e_uniform.METALLIC, shader_uniform_metallic)
		render_set_uniform(e_uniform.EMISSIVE, shader_uniform_emissive)
	}
	
	if (filterprev != null)
		gpu_set_tex_mip_bias(filterprev)
}
