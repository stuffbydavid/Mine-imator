/// render_world_block(chunks, resource, [rotate, size, [temp]])
/// @arg chunks
/// @arg resource
/// @arg [rotate
/// @arg size[
/// @arg temp]]

function render_world_block()
{
	var chunks, res, rotate, size, temp;
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
	
	if (!res_is_ready(res))
		res = mc_res
	
	var tex, texani;
	tex = res.block_sheet_texture
	if (res.block_sheet_ani_texture != null)
		texani = res.block_sheet_ani_texture[block_texture_get_frame()]
	else
		texani = mc_res.block_sheet_ani_texture[block_texture_get_frame()]
	
	var blend = shader_blend_color;
	render_set_texture(tex)
	
	// Rotate by 90 degrees for legacy support
	if (rotate && (!dev_mode || dev_mode_rotate_blocks))
		matrix_world_multiply_pre(matrix_create(point3D(0, size[Y] * block_size, 0), vec3(0, 0, 90), vec3(1)))
	
	if (chunks = null)
		return 0
	
	var vbufferarray = (object_index = obj_timeline ? visible_chunks_array[render_repeat[X]][render_repeat[Y]][render_repeat[Z]] : null);
	
	#region Depth 0
	
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH0][e_block_vbuffer.NORMAL]))
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH0, e_block_vbuffer.NORMAL)
	
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH0][e_block_vbuffer.GRASS]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res.color_grass), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH0, e_block_vbuffer.GRASS)
		render_set_uniform_color("uBlendColor", blend, shader_blend_alpha)
	}
	
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH0][e_block_vbuffer.ANIMATED]))
	{
		render_set_texture(texani)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH0, e_block_vbuffer.ANIMATED)	
	}
	
	render_set_texture(tex)
	
	#endregion
	
	#region Depth 1
	
	var filterprev;
				
	// Disable texture filtering on transparent blocks
	if (app.project_render_texture_filtering && !app.project_render_transparent_block_texture_filtering)
	{
		filterprev = gpu_get_tex_mip_bias()
		gpu_set_tex_mip_bias(-16)
		render_set_texture(tex)
	}
	
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH1][e_block_vbuffer.NORMAL]))
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.NORMAL)
	
	// Grass
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH1][e_block_vbuffer.GRASS]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res.color_grass), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.GRASS)
	}
	
	// Foliage
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH1][e_block_vbuffer.FOLIAGE]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res.color_foliage), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.FOLIAGE)
	}
	
	// Oak leaves
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH1][e_block_vbuffer.LEAVES_OAK]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res.color_leaves_oak), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_OAK)
	}
	
	// Spruce leaves
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH1][e_block_vbuffer.LEAVES_SPRUCE]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res.color_leaves_spruce), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_SPRUCE)
	}
	
	// Birch leaves
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH1][e_block_vbuffer.LEAVES_BIRCH]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res.color_leaves_birch), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_BIRCH)
	}
	
	// Jungle leaves
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH1][e_block_vbuffer.LEAVES_JUNGLE]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res.color_leaves_jungle), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_JUNGLE)
	}
	
	// Acacia leaves
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH1][e_block_vbuffer.LEAVES_ACACIA]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res.color_leaves_acacia), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_ACACIA)
	}
	
	// Dark oak leaves
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH1][e_block_vbuffer.LEAVES_DARK_OAK]))
	{
		render_set_uniform_color("uBlendColor", color_multiply(blend, res.color_leaves_dark_oak), shader_blend_alpha)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.LEAVES_DARK_OAK)
	}
	
	render_set_uniform_color("uBlendColor", blend, shader_blend_alpha)
	
	if (app.project_render_texture_filtering && !app.project_render_transparent_block_texture_filtering)
		gpu_set_tex_mip_bias(filterprev)
	
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH1][e_block_vbuffer.ANIMATED]))
	{
		render_set_texture(texani)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH1, e_block_vbuffer.ANIMATED)
	}
	
	render_set_texture(tex)
	
	#endregion
	
	#region Depth 2
	
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH2][e_block_vbuffer.NORMAL]))
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH2, e_block_vbuffer.NORMAL)
	
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH2][e_block_vbuffer.ANIMATED]))
	{
		render_set_texture(texani)
		render_chunks_vbuffer(chunks, e_block_depth.DEPTH2, e_block_vbuffer.ANIMATED)
	}
	
	if (vbufferarray = null || array_length(vbufferarray[e_block_depth.DEPTH2][e_block_vbuffer.WATER]))
	{
		if (render_mode != e_render_mode.HIGH_LIGHT_SUN_DEPTH &&
			render_mode != e_render_mode.HIGH_LIGHT_SPOT_DEPTH &&
			render_mode != e_render_mode.HIGH_LIGHT_POINT_DEPTH)
		{
			render_set_texture(texani)
			render_set_uniform_color("uBlendColor", color_multiply(blend, res.color_water), shader_blend_alpha)
			render_set_uniform_int("uIsWater", 1)
			render_set_uniform("uRoughness", .2)
			render_chunks_vbuffer(chunks, e_block_depth.DEPTH2, e_block_vbuffer.WATER)
			render_set_uniform_color("uBlendColor", blend, shader_blend_alpha)
			render_set_uniform_int("uIsWater", 0)
		}
	}
	
	#endregion
}
