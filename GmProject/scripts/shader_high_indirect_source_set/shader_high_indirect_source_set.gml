function shader_high_indirect_source_set(previousbuffer, previousamount)
{
	texture_set_stage(sampler_map[?"uNormalBuffer"], surface_get_texture(render_surface_normal))
	gpu_set_texrepeat_ext(sampler_map[?"uNormalBuffer"], false)
	
	texture_set_stage(sampler_map[?"uLightBuffer"], surface_get_texture(render_surface_shadows))
	gpu_set_texrepeat_ext(sampler_map[?"uLightBuffer"], false)

	texture_set_stage(sampler_map[?"uPreviousBuffer"], surface_get_texture(previousbuffer))
	gpu_set_texrepeat_ext(sampler_map[?"uPreviousBuffer"], false)
	
	render_set_uniform(e_uniform.PREVIOUS_AMOUNT, previousamount)
	render_set_uniform(e_uniform.GAMMA, render_gamma)
}
