/// shader_high_lighting_apply_set(shadows, mask, material)
/// @arg shadows
/// @arg mask
/// @arg material

function shader_high_lighting_apply_set(shadows, mask, material)
{
	render_set_uniform_int("uShadowsEnabled", render_shadows || render_ssao)
	
	if ((render_shadows || render_ssao) && surface_exists(shadows))
		texture_set_stage(sampler_map[?"uShadows"], surface_get_texture(shadows))
	
	if (render_shadows && surface_exists(render_surface_specular))
	{
		render_set_uniform_int("uSpecularEnabled", true)
		texture_set_stage(sampler_map[?"uSpecular"], surface_get_texture(render_surface_specular))
	}
	else
		render_set_uniform_int("uSpecularEnabled", false)
	
	if (render_shadows && surface_exists(render_surface_emissive))
		texture_set_stage(sampler_map[?"uEmissive"], surface_get_texture(render_surface_emissive))
	
	texture_set_stage(sampler_map[?"uMask"], surface_get_texture(mask))
	texture_set_stage(sampler_map[?"uMaterialBuffer"], surface_get_texture(material))
	
	render_set_uniform("uIndirectEnabled", render_indirect)
	render_set_uniform("uIndirectStrength", app.project_render_indirect_strength)
	
	render_set_uniform("uReflectionsEnabled", render_reflections)
	render_set_uniform_color("uFallbackColor", app.background_sky_color_final, 1)
	render_set_uniform("uGamma", render_gamma)
}
