function shader_high_indirect_resolve_set()
{
	texture_set_stage(sampler_handle[e_sampler.DEPTH_BUFFER], surface_get_texture(render_surface_depth))
	gpu_set_texrepeat_ext(sampler_handle[e_sampler.DEPTH_BUFFER], false)
	
	texture_set_stage(sampler_handle[e_sampler.NORMAL_BUFFER], surface_get_texture(render_surface_normal))
	gpu_set_texrepeat_ext(sampler_handle[e_sampler.NORMAL_BUFFER], false)
	
	texture_set_stage(sampler_handle[e_sampler.MATERIAL_BUFFER], surface_get_texture(render_surface_material))
	gpu_set_texrepeat_ext(sampler_handle[e_sampler.MATERIAL_BUFFER], false)
	
	texture_set_stage(sampler_handle[e_sampler.SOURCE_BUFFER], surface_get_texture(render_surface_hdr[0]))
	gpu_set_texrepeat_ext(sampler_handle[e_sampler.SOURCE_BUFFER], false)
	
	render_set_uniform_vec2(e_uniform.RAY_DATA_SIZE, surface_get_width(render_surface_indirect_raydata), surface_get_height(render_surface_indirect_raydata))
	render_set_uniform(e_uniform.NEAR, depth_near)
	render_set_uniform(e_uniform.FAR, depth_far)
	render_set_uniform(e_uniform.PROJ_MATRIX_INV, matrix_inverse_ext(proj_matrix))
	render_set_uniform(e_uniform.STRENGTH, app.project_render_indirect_strength)
	render_set_uniform_int(e_uniform.SAMPLE_AMOUNT, array_length(render_raytrace_kernel) / 2)
	render_set_uniform(e_uniform.SAMPLES, render_raytrace_kernel)
}
