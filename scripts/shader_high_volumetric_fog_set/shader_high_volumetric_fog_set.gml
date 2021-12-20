/// shader_high_volumetric_fog_set(depth, sundepth)
/// @arg depth
/// @arg sundepth

function shader_high_volumetric_fog_set(depth, sundepth)
{
	if (depth = undefined)
		return 0
	
	render_set_uniform("uSunNear", render_sun_near)
	render_set_uniform("uSunFar", render_sun_far)
	render_set_uniform("uSunMatrix", render_sun_matrix)
	render_set_uniform("uProjMatrixInv", matrix_inverse(proj_matrix))
	render_set_uniform("uViewMatrixInv", matrix_inverse(view_matrix))
	render_set_uniform_vec3("uSunDirection", render_sun_direction[X], render_sun_direction[Y], render_sun_direction[Z])
	
	if (app.background_sunlight_color_final != c_black)
	{
		render_set_uniform_int("uSunVisible", 1)
		
		texture_set_stage(sampler_map[?"uSunDepthBuffer"], surface_get_texture(sundepth))
		gpu_set_texfilter_ext(sampler_map[?"uSunDepthBuffer"], true)
	}
	else
		render_set_uniform_int("uSunVisible", 0)
	
	render_set_uniform("uNear", proj_depth_near)
	render_set_uniform("uFar", proj_depth_far)
	
	render_set_uniform("uOffset", render_volumetric_fog_offset)
	
	render_set_uniform_int("uFogAmbience", app.background_volumetric_fog_ambience)
	render_set_uniform_int("uFogNoise", app.background_volumetric_fog_noise)
	
	render_set_uniform("uScattering", app.background_volumetric_fog_scatter)
	render_set_uniform("uDensity", app.background_volumetric_fog_density / 100)
	
	render_set_uniform("uFogHeight", app.background_volumetric_fog_height)
	render_set_uniform("uFogHeightFade", app.background_volumetric_fog_height_fade)
	render_set_uniform("uFogNoiseScale", app.background_volumetric_fog_noise_scale)
	render_set_uniform("uFogNoiseContrast", app.background_volumetric_fog_noise_contrast + 1)
	render_set_uniform("uFogWind", app.background_volumetric_fog_wind)
	
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(depth))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer"], false)
	
	render_set_uniform_vec3("uCameraPosition", cam_from[X], cam_from[Y], cam_from[Z])
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
}
