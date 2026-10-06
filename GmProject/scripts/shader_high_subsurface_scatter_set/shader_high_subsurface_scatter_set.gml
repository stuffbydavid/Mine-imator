/// @arg sssurface
/// @arg rangesurface

function shader_high_subsurface_scatter_set(ssssurf, rangesurf)
{
	texture_set_stage(sampler_handle[e_sampler.SSS_BUFFER], surface_get_texture(ssssurf))
	gpu_set_texfilter_ext(sampler_handle[e_sampler.SSS_BUFFER], false)
	
	texture_set_stage(sampler_handle[e_sampler.SSS_RANGE_BUFFER], surface_get_texture(rangesurf))
	gpu_set_texfilter_ext(sampler_handle[e_sampler.SSS_RANGE_BUFFER], false)
	
	texture_set_stage(sampler_handle[e_sampler.DEPTH_BUFFER], surface_get_texture(render_surface_depth))
	gpu_set_texfilter_ext(sampler_handle[e_sampler.DEPTH_BUFFER], false)
	
	texture_set_stage(sampler_handle[e_sampler.DIRECT], surface_get_texture(render_surface_shadows))
	gpu_set_texfilter_ext(sampler_handle[e_sampler.DIRECT], false)
	
	texture_set_stage(sampler_handle[e_sampler.NOISE_BUFFER], surface_get_texture(render_sample_noise_texture))
	gpu_set_texfilter_ext(sampler_handle[e_sampler.NOISE_BUFFER], false)
	
	render_set_uniform(e_uniform.NOISE_SIZE, render_sample_noise_size)
	render_set_uniform(e_uniform.PROJ_MATRIX, proj_matrix)
	render_set_uniform_vec2(e_uniform.SCREEN_SIZE, render_width, render_height)
	render_set_uniform(e_uniform.NEAR, depth_near)
	render_set_uniform(e_uniform.FAR, depth_far)
	
	render_set_uniform_int(e_uniform.SAMPLES, app.project_render_subsurface_samples + 1)
	render_set_uniform(e_uniform.KERNEL, render_subsurface_kernel)
}
