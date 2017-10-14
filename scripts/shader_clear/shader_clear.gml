/// shader_clear()

if (texture_lib)
	external_call(lib_texture_reset_stage, sampler_map[?"uTexture"])

shader_reset()

if (!texture_lib)
	gpu_set_tex_mip_enable(mip_off)
	
shader_texture_surface = false
shader_texture_filter_linear = false
shader_texture_filter_mipmap = false