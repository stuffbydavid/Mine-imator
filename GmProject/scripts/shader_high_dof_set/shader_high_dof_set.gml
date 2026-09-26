/// shader_high_dof_set(blurbuffer)
/// @arg blurbuffer

function shader_high_dof_set(blurbuffer)
{
	texture_set_stage(sampler_map[?"uBlurBuffer"], surface_get_texture(blurbuffer))
	var pixelvariation = (renderer_current = e_renderer.REALISTIC) || app.project_render_dof_realistic_blur
	if (pixelvariation)
	{
		texture_set_stage(sampler_map[?"uNoiseBuffer"], surface_get_texture(render_sample_noise_texture))
		gpu_set_texrepeat_ext(sampler_map[?"uNoiseBuffer"], true)
		gpu_set_texfilter_ext(sampler_map[?"uNoiseBuffer"], false)
	}
	
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
	
	render_set_uniform("uBlurSize", render_camera.value[e_value.CAM_DOF_BLUR_SIZE])
	
	render_set_uniform("uBias", render_camera.value[e_value.CAM_DOF_BIAS])
	render_set_uniform("uThreshold", render_camera.value[e_value.CAM_DOF_THRESHOLD])
	render_set_uniform("uGain", render_camera.value[e_value.CAM_DOF_GAIN])
	
	var fringe = render_camera.value[e_value.CAM_DOF_FRINGE]
	render_set_uniform_int("uFringe", bool_to_float(fringe))
	if (fringe)
	{
		var fringesize = render_height / render_width * render_camera.value[e_value.CAM_DOF_BLUR_SIZE]
		var angle = -degtorad(render_camera.value[e_value.CAM_DOF_FRINGE_ANGLE_RED] + 180)
		var strength = render_camera.value[e_value.CAM_DOF_FRINGE_RED] * fringesize
		render_set_uniform_vec2("uFringeOffsetRed", cos(angle) * strength, sin(angle) * strength)
		angle = -degtorad(render_camera.value[e_value.CAM_DOF_FRINGE_ANGLE_GREEN] + 180)
		strength = render_camera.value[e_value.CAM_DOF_FRINGE_GREEN] * fringesize
		render_set_uniform_vec2("uFringeOffsetGreen", cos(angle) * strength, sin(angle) * strength)
		angle = -degtorad(render_camera.value[e_value.CAM_DOF_FRINGE_ANGLE_BLUE] + 180)
		strength = render_camera.value[e_value.CAM_DOF_FRINGE_BLUE] * fringesize
		render_set_uniform_vec2("uFringeOffsetBlue", cos(angle) * strength, sin(angle) * strength)
	}
	
	render_generate_dof_samples(render_camera.value[e_value.CAM_BLADE_AMOUNT], render_camera.value[e_value.CAM_BLADE_ANGLE], render_camera.value[e_value.CAM_DOF_BLUR_RATIO], render_camera.value[e_value.CAM_BLADE_STRETCH])
	render_set_uniform_int("uBladeAmount", render_camera.value[e_value.CAM_BLADE_AMOUNT])
	render_set_uniform("uBladeRotation", -degtorad(render_camera.value[e_value.CAM_BLADE_ANGLE]))
	render_set_uniform("uBlurRatio", render_camera.value[e_value.CAM_DOF_BLUR_RATIO])
	render_set_uniform("uBladeRounding", render_dof_blade_rounding)
	render_set_uniform("uBladeStretch", render_camera.value[e_value.CAM_BLADE_STRETCH])
	render_set_uniform_int("uPixelRotation", bool_to_float(pixelvariation))
	render_set_uniform("uNoiseSize", render_sample_noise_size)
	render_set_uniform_int("uSampleAmount", render_dof_sample_amount)
	render_set_uniform("uSamples", render_dof_samples)
	render_set_uniform("uWeightSamples", render_dof_weight_samples)
	render_set_uniform("uAreaSamples", render_dof_area_samples)
}
