/// shader_clear()

gpu_set_tex_mip_enable(mip_off)
texture_set_stage(0, 0)
shader_reset()
	
shader_texture_surface = false
shader_texture_filter_linear = false
shader_texture_filter_mipmap = false