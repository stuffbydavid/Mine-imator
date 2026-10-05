function shader_noise_set()
{
	texture_set_stage(sampler_map[?"uNoiseBuffer"], surface_get_texture(render_grain_noise))
	gpu_set_texrepeat_ext(sampler_map[?"uNoiseBuffer"], true)
	gpu_set_tex_filter_ext(sampler_map[?"uNoiseBuffer"], true)
	
	render_set_uniform_vec2(e_uniform.SCREEN_SIZE, render_width, render_height)
	
	render_set_uniform(e_uniform.STRENGTH, render_camera_effects[e_value.CAM_FX_GRAIN_STRENGTH])
	render_set_uniform(e_uniform.SATURATION, render_camera_effects[e_value.CAM_FX_GRAIN_SATURATION])
	render_set_uniform(e_uniform.SIZE, vec2_mul(vec2(max(ceil(render_width/8), ceil(render_height/8))), render_camera_effects[e_value.CAM_FX_GRAIN_SIZE]))
}
