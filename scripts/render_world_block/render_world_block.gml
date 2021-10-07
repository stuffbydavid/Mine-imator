/// render_world_block(chunks, resource, [rotate, size, [temp]])
/// @arg chunks
/// @arg resource
/// @arg [rotate
/// @arg size[
/// @arg temp]]

function render_world_block()
{
	var chunks, res, rotate, size, temp, deptharr;
	chunks = argument[0]
	res = argument[1]
	
	if (argument_count > 2)
	{
		rotate = argument[2]
		size = argument[3]
	}
	else
		rotate = false
	
	if (argument_count > 4)
		temp = argument[4]
	else
		temp = null
	
	if (!is_array(res))
		res = [res, mc_res, mc_res]
	
	if (!res_is_ready(res[0]))
		res[0] = mc_res
	
	if (!res_is_ready(res[1]))
		res[1] = mc_res
	
	if (!res_is_ready(res[2]))
		res[2] = mc_res
	
	var tex, texprev, texani;
	var mattex, mattexprev, mattexani;
	var normaltex, normaltexprev, normaltexani;
	
	render_set_uniform_int("uMaterialUseGlossiness", res[1].material_uses_glossiness)
	
	tex = res[0].block_sheet_texture
	mattex = res[1].block_sheet_material_texture
	normaltex = res[2].block_sheet_normal_texture
	
	texprev = tex
	mattexprev = mattex
	normaltexprev = normaltex
	
	if (res[0].block_sheet_ani_texture != null)
		texani = res[0].block_sheet_ani_texture[block_texture_get_frame()]
	else
		texani = mc_res.block_sheet_ani_texture[block_texture_get_frame()]
	
	if (res[1].block_sheet_ani_material_texture != null)
		mattexani = res[1].block_sheet_ani_material_texture[block_texture_get_frame()]
	else
		mattexani = mc_res.block_sheet_ani_material_texture[block_texture_get_frame()]
	
	// Set material values
	if (res[1] != mc_res)
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
		
		if (shader_uniform_brightness != 1)
		{
			shader_uniform_brightness = 1
			render_set_uniform("uBrightness", shader_uniform_brightness)
		}
	}
	
	if (res[2].block_sheet_ani_normal_texture != null)
		normaltexani = res[2].block_sheet_ani_normal_texture[block_texture_get_frame()]
	else
		normaltexani = mc_res.block_sheet_ani_normal_texture[block_texture_get_frame()]
	
	var blend = shader_blend_color;
	render_set_texture(tex)
	render_set_texture(mattex, "Material")
	render_set_texture(normaltex, "Normal")
	
	// Rotate by 90 degrees for legacy support
	if (rotate && (!dev_mode || dev_mode_rotate_blocks))
		matrix_world_multiply_pre(matrix_create(point3D(0, size[Y] * block_size, 0), vec3(0, 0, 90), vec3(1)))
	
	if (chunks = null)
		return 0
	
	var vbufferarray = (object_index = obj_timeline ? (visible_chunks_array = null ? null : visible_chunks_array[render_repeat[X]][render_repeat[Y]][render_repeat[Z]]) : null);
	
	if (object_index = obj_timeline && vbufferarray = null)
		return 0
	
	#region Depth 0
	
	if (object_index = obj_timeline)
		deptharr = vbufferarray[e_block_depth.DEPTH0]
	
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.NORMAL]))
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH0, e_block_vbuffer.NORMAL)
	
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.GRASS]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_grass), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH0, e_block_vbuffer.GRASS)
		render_set_uniform_color("uBlendColor", blend, shader_blend_alpha)
	}
	
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.ANIMATED]))
	{
		if (texani != texprev)
		{
			render_set_texture(texani)
			texprev = texani
		}
		
		if (mattexani != mattexprev)
		{
			render_set_texture(mattexani, "Material")
			mattexprev = mattexani
		}
		
		if (normaltexani != normaltexprev)
		{
			render_set_texture(normaltexani, "Normal")
			normaltexprev = normaltexani
		}
		
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH0, e_block_vbuffer.ANIMATED)	
	}
	
	if (tex != texprev)
	{
		render_set_texture(tex)
		texprev = tex
	}
	
	if (mattex != mattexprev)
	{
		render_set_texture(mattex, "Material")
		mattexprev = mattex
	}
	
	if (normaltex != normaltexprev)
	{
		render_set_texture(normaltex, "Normal")
		normaltexprev = normaltex
	}
	
	#endregion
	
	#region Depth 1
	
	var filterprev;
	
	if (object_index = obj_timeline)
		deptharr = vbufferarray[e_block_depth.DEPTH1]
	
	// Disable texture filtering on transparent blocks
	if (app.project_render_texture_filtering && !app.project_render_transparent_block_texture_filtering)
	{
		filterprev = gpu_get_tex_mip_bias()
		gpu_set_tex_mip_bias(-16)
		
		render_set_texture(tex)
		texprev = tex
		
		render_set_texture(mattex, "Material")
		mattexprev = mattex
		
		render_set_texture(normaltex, "Normal")
		normaltexprev = normaltex
	}
	
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.NORMAL]))
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.NORMAL)
	
	// Grass
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.GRASS]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_grass), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.GRASS)
	}
	
	// Foliage
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.FOLIAGE]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_foliage), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.FOLIAGE)
	}
	
	// Oak leaves
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.LEAVES_OAK]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_leaves_oak), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_OAK)
	}
	
	// Spruce leaves
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.LEAVES_SPRUCE]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_leaves_spruce), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_SPRUCE)
	}
	
	// Birch leaves
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.LEAVES_BIRCH]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_leaves_birch), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_BIRCH)
	}
	
	// Jungle leaves
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.LEAVES_JUNGLE]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_leaves_jungle), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_JUNGLE)
	}
	
	// Acacia leaves
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.LEAVES_ACACIA]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_leaves_acacia), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_ACACIA)
	}
	
	// Dark oak leaves
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.LEAVES_DARK_OAK]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_leaves_dark_oak), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_DARK_OAK)
	}
	
	render_set_uniform_color("uBlendColor", blend, shader_blend_alpha)
	
	if (app.project_render_texture_filtering && !app.project_render_transparent_block_texture_filtering)
		gpu_set_tex_mip_bias(filterprev)
	
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.ANIMATED]))
	{
		if (texani != texprev)
		{
			render_set_texture(texani)
			texprev = texani
		}
		
		if (mattexani != mattexprev)
		{
			render_set_texture(mattexani, "Material")
			mattexprev = mattexani
		}
		
		if (normaltexani != normaltexprev)
		{
			render_set_texture(normaltexani, "Normal")
			normaltexprev = normaltexani
		}
		
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.ANIMATED)
	}
	
	if (tex != texprev)
	{
		render_set_texture(tex)
		texprev = tex
	}
	
	if (mattex != mattexprev)
	{
		render_set_texture(mattex, "Material")
		mattexprev = mattex
	}
	
	if (normaltex != normaltexprev)
	{
		render_set_texture(normaltex, "Normal")
		normaltexprev = normaltex
	}
	
	#endregion
	
	#region Depth 2
	
	if (object_index = obj_timeline)
		deptharr = vbufferarray[e_block_depth.DEPTH2]
	
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.NORMAL]))
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH2, e_block_vbuffer.NORMAL)
	
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.ANIMATED]))
	{
		render_set_texture(texani)
		render_set_texture(mattexani, "Material")
		render_set_texture(normaltexani, "Normal")
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH2, e_block_vbuffer.ANIMATED)
	}
	
	if (vbufferarray = null || array_length(deptharr[e_block_vbuffer.WATER]))
	{
		if (render_mode != e_render_mode.HIGH_LIGHT_SUN_DEPTH &&
			render_mode != e_render_mode.HIGH_LIGHT_SPOT_DEPTH &&
			render_mode != e_render_mode.HIGH_LIGHT_POINT_DEPTH)
		{
			render_set_texture(texani)
			
			/*
			render_set_texture(mattexani, "Material")
			render_set_texture(normaltexani, "Normal")
			*/
			
			render_set_texture(spr_default_material, "Material")
			render_set_texture(spr_default_normal, "Normal")
			
			render_set_uniform_color("uBlendColor", color_multiply(blend, res[0].color_water), shader_blend_alpha)
			render_set_uniform_int("uIsWater", 1)
			
			if (shader_uniform_roughness != 0.2)
			{
				shader_uniform_roughness = 0.2
				render_set_uniform("uRoughness", shader_uniform_roughness)
			}
			
			if (shader_uniform_metallic != 0.0)
			{
				shader_uniform_metallic = 0.0
				render_set_uniform("uMetallic", shader_uniform_metallic)
			}
			
			if (shader_uniform_brightness != 0.0)
			{
				shader_uniform_brightness = 0.0
				render_set_uniform("uBrightness", shader_uniform_brightness)
			}
			
			render_chunks_vbuffer(chunks, e_block_depth.DEPTH2, e_block_vbuffer.WATER)
			render_set_uniform_color("uBlendColor", blend, shader_blend_alpha)
			render_set_uniform_int("uIsWater", 0)
		}
	}
	
	#endregion
}
