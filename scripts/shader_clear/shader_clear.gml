/// shader_clear()

gpu_set_tex_mip_enable(mip_off)
texture_set_stage(0, 0)

if (texture_lib && !is_undefined(sampler_map[?"uTexture"]))
	external_call(lib_texture_reset_stage, sampler_map[?"uTexture"])

shader_reset()
	
shader_texture_surface = false
shader_texture_filter_linear = false
shader_texture_filter_mipmap = false