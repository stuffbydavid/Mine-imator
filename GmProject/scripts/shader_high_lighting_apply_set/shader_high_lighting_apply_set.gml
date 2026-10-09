/// @arg shadowssurface
/// @arg ssaosurface
/// @arg masksurface
/// @arg materialsurface
/// @arg [fallbackonly]

function shader_high_lighting_apply_set(shadows, ssao, mask, material, fallbackonly = false)
{
	render_set_uniform_int(e_uniform.FALLBACK_ONLY, fallbackonly)
	
	if (renderer_current = e_renderer.STANDARD && app.env_fog_show && !fallbackonly)
	{
		render_set_uniform_int(e_uniform.FOG_APPLY, 1)
		texture_set_stage(sampler_handle[e_sampler.FOG_BUFFER], surface_get_texture(render_surface_fog))
	}
	else
		render_set_uniform_int(e_uniform.FOG_APPLY, 0)
	
	texture_set_stage(sampler_handle[e_sampler.MATERIAL_BUFFER], surface_get_texture(material))
	texture_set_stage(sampler_handle[e_sampler.DIFFUSE_BUFFER], surface_get_texture(render_surface_diffuse))
	texture_set_stage(sampler_handle[e_sampler.EMISSIVE], surface_get_texture(render_surface_normal))
	
	render_set_uniform(e_uniform.BACKGROUND_BRIGHTNESS, app.env_brightness)
	render_set_uniform_color(e_uniform.FALLBACK_COLOR, app.env_sky_color_final, 1)
	render_set_uniform_color(e_uniform.FOG_COLOR, app.env_fog_object_color_final, 1)
	render_set_uniform(e_uniform.GAMMA, render_gamma)
	render_set_uniform(e_uniform.PROJ_MATRIX_INV, matrix_inverse_ext(proj_matrix))
	
	shader_fog_fallback_set()
	
	if (fallbackonly)
		return 0
	
	render_set_uniform_int(e_uniform.SHADOWS_ENABLED, render_shadows)
	
	if (render_shadows && surface_exists(shadows))
		texture_set_stage(sampler_handle[e_sampler.SHADOWS], surface_get_texture(shadows))
	
	render_set_uniform_int(e_uniform.SSAO_ENABLED, render_ssao)
	render_set_uniform_int(e_uniform.SSAO_ALWAYS_VISIBLE, app.project_render_ssao_always_visible)
	
	if (render_ssao && surface_exists(ssao))
		texture_set_stage(sampler_handle[e_sampler.SSAO], surface_get_texture(ssao))
	
	if (surface_exists(render_surface_specular))
	{
		render_set_uniform_int(e_uniform.SPECULAR_ENABLED, true)
		texture_set_stage(sampler_handle[e_sampler.SPECULAR], surface_get_texture(render_surface_specular))
	}
	else
		render_set_uniform_int(e_uniform.SPECULAR_ENABLED, false)
	
	texture_set_stage(sampler_handle[e_sampler.MASK], surface_get_texture(mask))
	render_set_uniform_color(e_uniform.AMBIENT_COLOR, render_shadows ? app.env_ambient_color_final : c_white, 1)
	
	render_set_uniform(e_uniform.INDIRECT_ENABLED, render_indirect)
	render_set_uniform(e_uniform.INDIRECT_STRENGTH, app.project_render_indirect_strength)
	
	render_set_uniform_int(e_uniform.REFLECTIONS_ENABLED, render_reflections)
}
