/// shader_high_light_sun_set()

function shader_high_light_sun_set()
{
	render_set_uniform("uBrightness", 0)
	
	render_set_uniform_int("uIsGround", 0)
	render_set_uniform_int("uIsSky", 0)
	render_set_uniform_int("uIsWater", 0)
	
	render_set_uniform("uLightMatrix", render_sun_matrix)
	if (app.background_sunlight_follow)
		render_set_uniform_vec3("uSunAt", cam_from[X], cam_from[Y], 0)
	else
		render_set_uniform_vec3("uSunAt", 0, 0, 0)
	
	render_set_uniform_vec3("uLightPosition", render_light_from[X], render_light_from[Y], render_light_from[Z])
	render_set_uniform("uSunNear", render_sun_near)
	render_set_uniform("uSunFar", render_sun_far)
	render_set_uniform_color("uLightColor", render_light_color, 1)
	render_set_uniform("uLightStrength", render_light_strength)
	
	render_set_uniform_vec3("uLightDirection", render_sun_direction[X], render_sun_direction[Y], render_sun_direction[Z])
	
	render_set_uniform_int("uColoredShadows", app.setting_render_shadows_sun_colored)
	
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(render_surface_sun_buffer))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer"], true)
	
	texture_set_stage(sampler_map[?"uColorBuffer"], surface_get_texture(render_surface_sun_color_buffer))
	gpu_set_texfilter_ext(sampler_map[?"uColorBuffer"], true)
}
