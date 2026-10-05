function shader_high_ssao_set()
{
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(render_surface_depth))
	texture_set_stage(sampler_map[?"uNormalBuffer"], surface_get_texture(render_surface_normal))
	texture_set_stage(sampler_map[?"uMaterialBuffer"], surface_get_texture(render_surface_material))
	texture_set_stage(sampler_map[?"uNoiseBuffer"], surface_get_texture(render_sample_noise_texture))
	gpu_set_texrepeat_ext(sampler_map[?"uDepthBuffer"], false)
	gpu_set_texrepeat_ext(sampler_map[?"uNormalBuffer"], false)
	gpu_set_texrepeat_ext(sampler_map[?"uMaterialBuffer"], false)
	gpu_set_texrepeat_ext(sampler_map[?"uNoiseBuffer"], true)
	gpu_set_texfilter_ext(sampler_map[?"uNoiseBuffer"], false)
	
	render_set_uniform(e_uniform.NEAR, depth_near)
	render_set_uniform(e_uniform.FAR, depth_far)
	render_set_uniform(e_uniform.PROJ_MATRIX, proj_matrix)
	render_set_uniform(e_uniform.PROJ_MATRIX_INV, matrix_inverse_ext(proj_matrix))
	render_set_uniform_vec2(e_uniform.SCREEN_SIZE, render_width, render_height)
	render_set_uniform(e_uniform.NOISE_SIZE, render_sample_noise_size)
	
	render_set_uniform(e_uniform.KERNEL, render_ssao_kernel)
	render_set_uniform(e_uniform.RADIUS, app.project_render_ssao_radius)
	render_set_uniform(e_uniform.POWER, app.project_render_ssao_power)
	render_set_uniform_color(e_uniform.COLOR, app.project_render_ssao_color, 1)
}
