/// render_world_sky_clouds()
/// @desc Renders the cloud models.

function render_world_sky_clouds()
{
	if (!background_sky_clouds_show || !render_background || render_mode = e_render_mode.DEPTH_NO_SKY)
		return 0
	
	if (render_mode = e_render_mode.SCENE_TEST || render_mode = e_render_mode.AO_MASK)
		render_set_uniform_color("uReplaceColor", c_black, 1)
	
	var res = background_sky_clouds_tex;
	if (!res_is_ready(res))
		res = mc_res
	
	// Shading
	render_set_uniform_int("uIsSky", 1)
	render_set_uniform_color("uBlendColor", background_sky_clouds_final, background_clouds_alpha)
	render_set_uniform_color("uGlowColor", c_black, 1)
	render_set_uniform_int("uGlowTexture", 0)
	render_set_uniform("uMetallic", 0)
	render_set_uniform("uRoughness", 1)
	render_set_uniform("uEmissive", 0)
	render_set_uniform("uLightSpecular", 0)
	
	// Texture
	if (res.type = e_res_type.PACK)
		render_set_texture(res.clouds_texture)
	else
		render_set_texture(res.texture)
	
	render_set_texture(spr_default_material, "Material")
	render_set_texture(spr_default_normal, "Normal")
	
	// Disable fog
	if (!background_fog_show || !background_fog_sky)
		render_set_uniform("uFogShow", 0)
	
	for (var i = 0; i < array_length(background_sky_clouds_vbuffer_pos); i++)
		vbuffer_render(background_sky_clouds_vbuffer, background_sky_clouds_vbuffer_pos[i])
	
	// Reset
	render_set_uniform_int("uIsSky", 0)
	render_set_uniform("uLightSpecular", render_light_specular_strength)
	if (!background_fog_show || !background_fog_sky)
		render_set_uniform("uFogShow", app.background_fog_show)
}
