/// shader_high_lighting_apply_set(shadows, ssao, mask, material)
/// @arg shadows
/// @arg ssao
/// @arg mask
/// @arg material
/// @arg [fallbackonly]

function shader_high_lighting_apply_set(shadows, ssao, mask, material, fallbackonly = false)
{
	render_set_uniform_int("uFallbackOnly", fallbackonly)
	texture_set_stage(sampler_map[?"uMaterialBuffer"], surface_get_texture(material))
	texture_set_stage(sampler_map[?"uDiffuseBuffer"], surface_get_texture(render_surface_diffuse))
	render_set_uniform_color("uFallbackColor", app.background_sky_color_final, 1)
	render_set_uniform("uGamma", render_gamma)
	
	if (fallbackonly)
		return
	
	render_set_uniform_int("uShadowsEnabled", render_shadows)
	
	if (render_shadows && surface_exists(shadows))
		texture_set_stage(sampler_map[?"uShadows"], surface_get_texture(shadows))
	
	render_set_uniform_int("uSSAOEnabled", render_ssao)
	render_set_uniform_int("uSSAOAlwaysVisible", app.project_render_ssao_always_visible)
	
	if (render_ssao && surface_exists(ssao))
		texture_set_stage(sampler_map[?"uSSAO"], surface_get_texture(ssao))
	
	if (surface_exists(render_surface_specular))
	{
		render_set_uniform_int("uSpecularEnabled", true)
		texture_set_stage(sampler_map[?"uSpecular"], surface_get_texture(render_surface_specular))
	}
	else
		render_set_uniform_int("uSpecularEnabled", false)
	
	if ((render_shadows || render_ssao) && surface_exists(render_surface_normal))
		texture_set_stage(sampler_map[?"uEmissive"], surface_get_texture(render_surface_normal))
	
	texture_set_stage(sampler_map[?"uMask"], surface_get_texture(mask))
	render_set_uniform_color("uAmbientColor", render_shadows ? app.background_ambient_color_final : c_white, 1)
	
	render_set_uniform("uIndirectEnabled", render_indirect)
	render_set_uniform("uIndirectStrength", app.project_render_indirect_strength)
	
	render_set_uniform_int("uReflectionsEnabled", render_reflections)
}
