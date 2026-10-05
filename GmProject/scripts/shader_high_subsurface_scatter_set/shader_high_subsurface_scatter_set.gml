/// @arg sssurface
/// @arg rangesurface

function shader_high_subsurface_scatter_set(ssssurf, rangesurf)
{
	texture_set_stage(sampler_map[?"uSSSBuffer"], surface_get_texture(ssssurf))
	gpu_set_texfilter_ext(sampler_map[?"uSSSBuffer"], false)
	
	texture_set_stage(sampler_map[?"uSSSRangeBuffer"], surface_get_texture(rangesurf))
	gpu_set_texfilter_ext(sampler_map[?"uSSSRangeBuffer"], false)
	
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(render_surface_depth))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer"], false)
	
	texture_set_stage(sampler_map[?"uDirect"], surface_get_texture(render_surface_shadows))
	gpu_set_texfilter_ext(sampler_map[?"uDirect"], false)
	
	texture_set_stage(sampler_map[?"uNoiseBuffer"], surface_get_texture(render_sample_noise_texture))
	gpu_set_texfilter_ext(sampler_map[?"uNoiseBuffer"], false)
	
	render_set_uniform(e_uniform.NOISE_SIZE, render_sample_noise_size)
	render_set_uniform(e_uniform.PROJ_MATRIX, proj_matrix)
	render_set_uniform_vec2(e_uniform.SCREEN_SIZE, render_width, render_height)
	render_set_uniform(e_uniform.NEAR, depth_near)
	render_set_uniform(e_uniform.FAR, depth_far)
	
	render_set_uniform_int(e_uniform.SAMPLES, app.project_render_subsurface_samples + 1)
	render_set_uniform(e_uniform.KERNEL, render_subsurface_kernel)
}
