function shader_high_indirect_source_set(previousbuffer, previousamount)
{
	texture_set_stage(sampler_handle[e_sampler.NORMAL_BUFFER], surface_get_texture(render_surface_normal))
	gpu_set_texrepeat_ext(sampler_handle[e_sampler.NORMAL_BUFFER], false)
	
	texture_set_stage(sampler_handle[e_sampler.LIGHT_BUFFER], surface_get_texture(render_surface_shadows))
	gpu_set_texrepeat_ext(sampler_handle[e_sampler.LIGHT_BUFFER], false)

	texture_set_stage(sampler_handle[e_sampler.PREVIOUS_BUFFER], surface_get_texture(previousbuffer))
	gpu_set_texrepeat_ext(sampler_handle[e_sampler.PREVIOUS_BUFFER], false)
	
	render_set_uniform(e_uniform.PREVIOUS_AMOUNT, previousamount)
	render_set_uniform(e_uniform.GAMMA, render_gamma)
}
