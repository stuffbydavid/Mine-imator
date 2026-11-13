/// @desc Renders clouds without lighting or material setup in fast passes.

function render_world_sky_clouds_fast()
{
	var res, twopass;
	res = res_eval(env_sky_clouds_tex)
	twopass = (render_mode != e_render_mode.DEPTH)
	
	render_apply_res(res)
	
	if (render_mode != e_render_mode.CLICK)
		render_set_uniform_color(e_uniform.BLEND_COLOR, c_white, env_clouds_alpha)
	
	// Texture
	if (res.type = e_res_type.PACK)
		render_set_texture(res, res.clouds_texture)
	else
		render_set_texture(res, res.texture)
	
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
	
	return 0
}
