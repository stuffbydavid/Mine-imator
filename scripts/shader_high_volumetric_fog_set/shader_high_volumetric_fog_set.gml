/// shader_high_volumetric_fog_set(depth)
/// @arg depth

function shader_high_volumetric_fog_set(depthsurf)
{
	if (depthsurf = undefined)
		return 0
	
	render_set_uniform("uSunNear", [render_cascades[0].near, render_cascades[1].near, render_cascades[2].near])
	render_set_uniform("uSunFar", [render_cascades[0].far, render_cascades[1].far, render_cascades[2].far])
	render_set_uniform("uViewMatrix", view_matrix)
	render_set_uniform("uProjMatrix", proj_matrix)
	render_set_uniform("uProjMatrixInv", matrix_inverse(proj_matrix))
	render_set_uniform("uViewMatrixInv", matrix_inverse(view_matrix))
	render_set_uniform_vec3("uSunDirection", render_sun_direction[X], render_sun_direction[Y], render_sun_direction[Z])
	
	if (app.background_sunlight_color_final != c_black)
	{
		render_set_uniform_int("uSunVisible", 1)
		
		texture_set_stage(sampler_map[?"uDepthBuffer0"], surface_get_texture(render_surface_sun_buffer[0]))
		gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer0"], true)
		
		texture_set_stage(sampler_map[?"uDepthBuffer1"], surface_get_texture(render_surface_sun_buffer[1]))
		gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer1"], true)
		
		texture_set_stage(sampler_map[?"uDepthBuffer2"], surface_get_texture(render_surface_sun_buffer[2]))
		gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer2"], true)
		
		render_set_uniform("uLightMatBiasMVP", array_add(array_add(array_copy_1d(render_cascades[0].matBias), render_cascades[1].matBias), render_cascades[2].matBias))
		render_set_uniform("uCascadeEndClipSpace", [render_cascades[0].clipEndDepth, render_cascades[1].clipEndDepth, render_cascades[2].clipEndDepth])
	}
	else
		render_set_uniform_int("uSunVisible", 0)
	
	render_set_uniform("uNear", proj_depth_near)
	render_set_uniform("uFar", proj_depth_far)
	
	render_set_uniform_int("uFogAmbience", app.background_volumetric_fog_ambience)
	render_set_uniform_int("uFogNoise", app.background_volumetric_fog_noise)
	
	render_set_uniform("uScattering", app.background_volumetric_fog_scatter)
	render_set_uniform("uDensity", app.background_volumetric_fog_density / 100)
	
	render_set_uniform("uFogHeight", app.background_volumetric_fog_height)
	render_set_uniform("uFogHeightFade", app.background_volumetric_fog_height_fade)
	render_set_uniform("uFogNoiseScale", app.background_volumetric_fog_noise_scale)
	render_set_uniform("uFogNoiseContrast", app.background_volumetric_fog_noise_contrast + 1)
	render_set_uniform("uFogWind", app.background_volumetric_fog_wind)
	
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(depthsurf))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer"], false)
	
	render_set_uniform_vec3("uCameraPosition", cam_from[X], cam_from[Y], cam_from[Z])
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
	
	texture_set_stage(sampler_map[?"uNoiseBuffer"], surface_get_texture(render_sample_noise_texture))
	gpu_set_texrepeat_ext(sampler_map[?"uNoiseBuffer"], true)
	render_set_uniform("uNoiseSize", render_sample_noise_size)
	
	render_set_uniform_int("uFogAmbience", app.background_volumetric_fog_ambience)
	
	render_set_uniform_color("uColor", app.background_volumetric_fog_color, 1)
	render_set_uniform_color("uSunColor", app.background_sunlight_color_final, 1)
	render_set_uniform_color("uAmbientColor", app.background_ambient_color_final, 1)
}
