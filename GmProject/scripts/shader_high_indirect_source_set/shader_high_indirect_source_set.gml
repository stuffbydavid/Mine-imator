/// shader_high_indirect_source_set()

function shader_high_indirect_source_set()
{
	texture_set_stage(sampler_map[?"uNormalBuffer"], surface_get_texture(render_surface_normal))
	gpu_set_texrepeat_ext(sampler_map[?"uNormalBuffer"], false)
	
	texture_set_stage(sampler_map[?"uLightBuffer"], surface_get_texture(render_surface_shadows))
	gpu_set_texrepeat_ext(sampler_map[?"uLightBuffer"], false)
	
	render_set_uniform("uGamma", render_gamma)
}
