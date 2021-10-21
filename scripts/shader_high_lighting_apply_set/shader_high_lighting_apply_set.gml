/// shader_high_lighting_apply_set(ssao, shadows, mask, material)
/// @arg ssao
/// @arg shadows
/// @arg mask
/// @arg material

function shader_high_lighting_apply_set(ssao, shadows, mask, material)
{
	render_set_uniform_int("uSSAOEnabled", render_ssao)
	
	if (render_ssao && surface_exists(ssao))
		texture_set_stage(sampler_map[?"uSSAO"], surface_get_texture(ssao))
	
	render_set_uniform_int("uShadowsEnabled", render_shadows)
	
	if (render_shadows && surface_exists(shadows) && surface_exists(render_surface_specular))
	{
		texture_set_stage(sampler_map[?"uShadows"], surface_get_texture(shadows))
		texture_set_stage(sampler_map[?"uSpecular"], surface_get_texture(render_surface_specular))
	}
	
	if (render_shadows && surface_exists(render_surface_indirect))
		texture_set_stage(sampler_map[?"uIndirect"], surface_get_texture(render_surface_indirect))
	
	texture_set_stage(sampler_map[?"uMask"], surface_get_texture(mask))
	texture_set_stage(sampler_map[?"uMaterialBuffer"], surface_get_texture(material))
	
	render_set_uniform_color("uAmbientColor", app.background_ambient_color_final, 1)
	
	render_set_uniform("uIndirectEnabled", render_indirect)
	render_set_uniform("uIndirectStrength", app.project_render_indirect_strength)
	
	render_set_uniform("uReflectionsEnabled", render_reflections)
	render_set_uniform_color("uFallbackColor", app.background_sky_color_final, 1)
}
