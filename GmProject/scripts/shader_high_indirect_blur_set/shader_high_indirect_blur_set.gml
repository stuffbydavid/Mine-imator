function shader_high_indirect_blur_set()
{
	texture_set_stage(sampler_handle[e_sampler.DEPTH_BUFFER], surface_get_texture(render_surface_depth))
	gpu_set_texrepeat_ext(sampler_handle[e_sampler.DEPTH_BUFFER], false)
	
	texture_set_stage(sampler_handle[e_sampler.NORMAL_BUFFER], surface_get_texture(render_surface_normal))
	gpu_set_texrepeat_ext(sampler_handle[e_sampler.NORMAL_BUFFER], false)
	
	texture_set_stage(sampler_handle[e_sampler.NOISE_BUFFER], surface_get_texture(render_sample_noise_texture))
	gpu_set_texrepeat_ext(sampler_handle[e_sampler.NOISE_BUFFER], true)
	gpu_set_texfilter_ext(sampler_handle[e_sampler.NOISE_BUFFER], false)
	
	render_set_uniform(e_uniform.NOISE_SIZE, render_sample_noise_size)
	render_set_uniform(e_uniform.NEAR, depth_near)
	render_set_uniform(e_uniform.FAR, depth_far)
	render_set_uniform(e_uniform.PROJ_MATRIX_INV, matrix_inverse_ext(proj_matrix))
	render_set_uniform_vec2(e_uniform.SCREEN_SIZE, render_width, render_height)
	render_set_uniform(e_uniform.SAMPLES, render_samples)
	render_set_uniform(e_uniform.BLUR_SIZE, app.project_render_indirect_blur_radius)
}
