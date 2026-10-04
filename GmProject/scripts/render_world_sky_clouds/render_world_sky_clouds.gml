/// @desc Renders the cloud models.

function render_world_sky_clouds()
{
	if (!env_sky_clouds_show || !render_background)
		return 0
	
	if (render_mode = e_render_mode.SCENE_TEST)
		render_set_uniform_color("uReplaceColor", c_black, 1)

	if (render_mode = e_render_mode.G_BUFFERS)
		render_set_uniform("uSSAO", 0)
	
	var res = res_eval(env_sky_clouds_tex);
	render_apply_res(res)
	
	// Shading
	render_set_uniform_int("uIsSky", 1)
	render_set_uniform_color("uBlendColor", env_sky_clouds_final, env_clouds_alpha)
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
	if (!env_fog_show || !env_fog_sky)
		render_set_uniform("uFogShow", 0)
	
	// Only draw clouds' depth
	gpu_set_blendenable(false)
	gpu_set_colorwriteenable(false, false, false, false)
	for (var i = 0; i < array_length(env_sky_clouds_vbuffer_pos); i++)
		vbuffer_render(env_sky_clouds_vbuffer, env_sky_clouds_vbuffer_pos[i], point3D(0, 0, 90))
	
	// Re-draw clouds to the written depth
	gpu_set_colorwriteenable(true, true, true, true)
	gpu_set_blendenable(true)
	gpu_set_zwriteenable(false)
	gpu_set_zfunc(cmpfunc_equal)
	
	for (var i = 0; i < array_length(env_sky_clouds_vbuffer_pos); i++)
		vbuffer_render(env_sky_clouds_vbuffer, env_sky_clouds_vbuffer_pos[i], point3D(0, 0, 90))
	
	// Restore z draw
	gpu_set_zfunc(cmpfunc_lessequal)
	gpu_set_zwriteenable(true)
	
	// Reset
	render_set_uniform_int("uIsSky", 0)
	render_set_uniform("uLightSpecular", render_light_specular_strength)
	if (!env_fog_show || !env_fog_sky)
		render_set_uniform("uFogShow", app.env_fog_show)
}
