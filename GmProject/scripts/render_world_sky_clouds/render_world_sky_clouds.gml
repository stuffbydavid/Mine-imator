/// @desc Renders the cloud models.

function render_world_sky_clouds()
{
	if (!env_sky_clouds_show || !render_background)
		return 0
	
	if (render_mode = e_render_mode.SCENE_TEST || render_mode = e_render_mode.COLOR)
		render_set_uniform_color(e_uniform.REPLACE_COLOR, c_black, 1)

	if (render_mode = e_render_mode.G_BUFFERS)
		render_set_uniform(e_uniform.SSAO, 0)
	
	var res, twopass;
	res = res_eval(env_sky_clouds_tex)
	twopass = (render_mode != e_render_mode.DEPTH && render_mode != e_render_mode.G_BUFFERS)
	if (render_mode = e_render_mode.AUXILIARY && !render_auxiliary_material && !render_glow)
		twopass = false
	
	render_apply_res(res)
	
	// Shading
	render_set_uniform_int(e_uniform.IS_SKY, 1)
	render_set_uniform_color(e_uniform.BLEND_COLOR, env_sky_clouds_final, env_clouds_alpha)
	render_set_uniform_color(e_uniform.GLOW_COLOR, c_black, 1)
	render_set_uniform_int(e_uniform.GLOW_TEXTURE, 0)
	render_set_uniform(e_uniform.METALLIC, 0)
	render_set_uniform(e_uniform.ROUGHNESS, 1)
	render_set_uniform(e_uniform.EMISSIVE, 0)
	render_set_uniform(e_uniform.LIGHT_SPECULAR, 0)
	
	// Texture
	if (res.type = e_res_type.PACK)
		render_set_texture(res, res.clouds_texture)
	else
		render_set_texture(res, res.texture)
	
	render_set_material_textures_none()
	render_set_uniform_int(e_uniform.MATERIAL_FORMAT, e_material.FORMAT_NONE)
	
	// Disable fog
	if (!env_fog_show || !env_fog_sky)
		render_set_uniform(e_uniform.FOG_SHOW, 0)
	
	if (twopass)
	{
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
	}
	
	for (var i = 0; i < array_length(env_sky_clouds_vbuffer_pos); i++)
		vbuffer_render(env_sky_clouds_vbuffer, env_sky_clouds_vbuffer_pos[i], point3D(0, 0, 90))
	
	if (twopass)
	{
		// Restore z draw
		gpu_set_zfunc(cmpfunc_lessequal)
		gpu_set_zwriteenable(true)
	}
	
	// Reset
	render_set_uniform_int(e_uniform.IS_SKY, 0)
	render_set_uniform(e_uniform.LIGHT_SPECULAR, render_light_specular_strength)
	if (!env_fog_show || !env_fog_sky)
		render_set_uniform(e_uniform.FOG_SHOW, app.env_fog_show)
}
