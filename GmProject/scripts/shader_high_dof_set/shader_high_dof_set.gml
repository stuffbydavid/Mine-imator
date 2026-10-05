function shader_high_dof_set(blurbuffer)
{
	texture_set_stage(sampler_map[?"uBlurBuffer"], surface_get_texture(blurbuffer))
	
	var pixelvariation = (renderer_current = e_renderer.REALISTIC || app.project_render_dof_realistic_blur);
	if (pixelvariation)
	{
		texture_set_stage(sampler_map[?"uNoiseBuffer"], surface_get_texture(render_sample_noise_texture))
		gpu_set_texrepeat_ext(sampler_map[?"uNoiseBuffer"], true)
		gpu_set_texfilter_ext(sampler_map[?"uNoiseBuffer"], false)
	}
	
	render_set_uniform_vec2(e_uniform.SCREEN_SIZE, render_width, render_height)
	
	render_set_uniform(e_uniform.BLUR_SIZE, render_camera_effects[e_value.CAM_FX_DOF_BLUR_SIZE])
	
	render_set_uniform(e_uniform.BIAS, render_camera_effects[e_value.CAM_FX_DOF_BIAS])
	render_set_uniform(e_uniform.THRESHOLD, render_camera_effects[e_value.CAM_FX_DOF_THRESHOLD])
	render_set_uniform(e_uniform.GAIN, render_camera_effects[e_value.CAM_FX_DOF_GAIN])
	
	var fringe = render_camera_effects[e_value.CAM_FX_DOF_FRINGE];
	render_set_uniform_int(e_uniform.FRINGE, bool_to_float(fringe))
	if (fringe)
	{
		var fringesize, angle, strength;
		fringesize = render_height / render_width * render_camera_effects[e_value.CAM_FX_DOF_BLUR_SIZE]
		
		angle = -degtorad(render_camera_effects[e_value.CAM_FX_DOF_FRINGE_ANGLE_RED] + 180)
		strength = render_camera_effects[e_value.CAM_FX_DOF_FRINGE_RED] * fringesize
		render_set_uniform_vec2(e_uniform.FRINGE_OFFSET_RED, cos(angle) * strength, sin(angle) * strength)
		
		angle = -degtorad(render_camera_effects[e_value.CAM_FX_DOF_FRINGE_ANGLE_GREEN] + 180)
		strength = render_camera_effects[e_value.CAM_FX_DOF_FRINGE_GREEN] * fringesize
		render_set_uniform_vec2(e_uniform.FRINGE_OFFSET_GREEN, cos(angle) * strength, sin(angle) * strength)
		
		angle = -degtorad(render_camera_effects[e_value.CAM_FX_DOF_FRINGE_ANGLE_BLUE] + 180)
		strength = render_camera_effects[e_value.CAM_FX_DOF_FRINGE_BLUE] * fringesize
		render_set_uniform_vec2(e_uniform.FRINGE_OFFSET_BLUE, cos(angle) * strength, sin(angle) * strength)
	}
	
	render_generate_dof_samples(render_camera_effects[e_value.CAM_FX_BLADE_AMOUNT], render_camera_effects[e_value.CAM_FX_BLADE_ANGLE], render_camera_effects[e_value.CAM_FX_DOF_BLUR_RATIO], render_camera_effects[e_value.CAM_FX_BLADE_STRETCH])
	render_set_uniform_int(e_uniform.BLADE_AMOUNT, render_camera_effects[e_value.CAM_FX_BLADE_AMOUNT])
	render_set_uniform(e_uniform.BLADE_ROTATION, -degtorad(render_camera_effects[e_value.CAM_FX_BLADE_ANGLE]))
	render_set_uniform(e_uniform.BLUR_RATIO, render_camera_effects[e_value.CAM_FX_DOF_BLUR_RATIO])
	render_set_uniform(e_uniform.BLADE_ROUNDING, render_dof_blade_rounding)
	render_set_uniform(e_uniform.BLADE_STRETCH, render_camera_effects[e_value.CAM_FX_BLADE_STRETCH])
	render_set_uniform_int(e_uniform.PIXEL_ROTATION, bool_to_float(pixelvariation))
	render_set_uniform(e_uniform.NOISE_SIZE, render_sample_noise_size)
	render_set_uniform_int(e_uniform.SAMPLE_AMOUNT, render_dof_sample_amount)
	render_set_uniform(e_uniform.SAMPLES, render_dof_samples)
	render_set_uniform(e_uniform.WEIGHT_SAMPLES, render_dof_weight_samples)
	render_set_uniform(e_uniform.AREA_SAMPLES, render_dof_area_samples)
}
