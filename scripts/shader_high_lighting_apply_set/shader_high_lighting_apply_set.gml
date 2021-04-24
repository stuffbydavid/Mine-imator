/// shader_high_lighting_apply_set(ssao, shadows, mask)
/// @arg ssao
/// @arg shadows
/// @arg mask

function shader_high_lighting_apply_set(ssao, shadows, mask)
{
	render_set_uniform_int("uSSAOEnabled", app.setting_render_ssao)
	
	if (app.setting_render_ssao && surface_exists(ssao))
		texture_set_stage(sampler_map[?"uSSAO"], surface_get_texture(ssao))
	
	render_set_uniform_int("uShadowsEnabled", app.setting_render_shadows)
	
	if (app.setting_render_shadows && surface_exists(shadows))
		texture_set_stage(sampler_map[?"uShadows"], surface_get_texture(shadows))
	
	if (app.setting_render_shadows && surface_exists(render_surface_indirect))
		texture_set_stage(sampler_map[?"uIndirect"], surface_get_texture(render_surface_indirect))
	
	texture_set_stage(sampler_map[?"uMask"], surface_get_texture(mask))
	
	render_set_uniform_color("uAmbientColor", app.background_ambient_color_final, 1)
	
	render_set_uniform("uIndirectEnabled", app.setting_render_indirect)
	render_set_uniform("uIndirectStrength", app.setting_render_indirect_strength)
}
