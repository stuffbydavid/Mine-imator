/// @desc Draws the sky or custom background as either a skybox or skysphere.

function render_world_sky()
{
	if (!render_background)
		return 0
	
	var hashprev = render_alpha_hash;
	render_alpha_hash = false
	render_set_uniform_int(e_uniform.ALPHA_HASH, render_alpha_hash)
	
	// Choose shader
	render_shader_obj = shader_map[?shader_blend]
	with (render_shader_obj)
		shader_use()
	
	var dis = project_render_distance * 0.75;
	gpu_set_zwriteenable(false)
	
	// Image
	if (env_background_image_show && env_background_image != null && env_background_image_type != "image")
	{
		var vbuf;
		
		if (env_background_image_type = "sphere") // Sphere
		{
			if (!env_background_image_sphere_vbuffer)
				env_background_image_sphere_vbuffer = vbuffer_create_sphere(1, point2D(1, 0), point2D(0, 1), 32, true, true)
			 vbuf = env_background_image_sphere_vbuffer
		}
		else if (env_background_image_type = "box") // Box
		{
			if (env_background_image_box_mapped)
			{
				if (!env_background_image_cube_mapped_vbuffer)
					env_background_image_cube_mapped_vbuffer = vbuffer_create_cube(0.75, point2D(0, 0), point2D(1, 1), -1, 1, true, true)
				vbuf = env_background_image_cube_mapped_vbuffer
			}
			else
			{
				if (!env_background_image_cube_vbuffer)
					env_background_image_cube_vbuffer = vbuffer_create_cube(0.75, point2D(1, 0), point2D(0, 1), 1, 1, true, false)
				vbuf = env_background_image_cube_vbuffer
			}
		}
		
		render_set_uniform_color(e_uniform.BLEND_COLOR, c_white, 1)
		render_set_texture(env_background_image.texture)
		vbuffer_render(vbuf, cam_from, point3D(0, 0, env_background_image_rotation), vec3(dis))
	}
	
	// Fog
	if (env_fog_show && env_fog_sky)
	{
		if (env_fog_vbuffer = null)
			env_fog_vbuffer = vbuffer_create_sphere(1, point2D(0, 0), point2D(1, 1), 16, true, true)
		
		gpu_set_texrepeat(false)
		
		shader_texture_filter_linear = false
		render_set_uniform_color(e_uniform.BLEND_COLOR, env_fog_color_final, 1)
		render_set_texture(spr_fog)
		
		// Fog sphere radius cannot exceed render distance
		var fogscalemath, fogscalexy, fogscalez;
		fogscalemath = ((env_fog_height / 1000) + ((env_fog_height / 1000) * max(env_sunrise_alpha, env_sunset_alpha)))
		fogscalexy = fogscalemath < 1 ? dis : dis / fogscalemath
		fogscalez = fogscalemath > 1 ? dis : dis * fogscalemath
		vbuffer_render(env_fog_vbuffer, cam_from, vec3(0), vec3(fogscalexy, fogscalexy, fogscalez))
		
		//shader_texture_filter_linear = false
		
		gpu_set_texrepeat(true)
	}
	
	// Sky
	if (!env_background_image_show)
	{
		var skymat = matrix_build(cam_from[X], cam_from[Y], cam_from[Z], env_sky_time, 0, env_sky_rotation, 1, 1, 1);
		
		gpu_set_blendmode(bm_add)
		
		// Stars
		if (env_night_alpha > 0)
		{
			if (env_sky_stars_vbuffer = null)
				env_sky_stars_vbuffer = vbuffer_create_cube(0.75, point2D(0, 0), point2D(2, 2), false, false, true, false)
			
			render_set_uniform_color(e_uniform.BLEND_COLOR, env_night_sky_stars_color, env_night_alpha)
			render_set_texture(spr_stars)
			vbuffer_render_matrix(env_sky_stars_vbuffer, matrix_multiply(matrix_build(0, 0, 0, 0, 0, 0, dis, dis, dis), skymat))
		}
		
		// Sun
		var vis = percent(vec3_dot(env_sun_direction, vec3(0, 0, 1)), -0.15, 0);
		
		if (env_sky_sun_moon_vbuffer = null)
			env_sky_sun_moon_vbuffer = vbuffer_create_surface(1, point2D(0, 0), point2D(1, 1), false)
		
		render_set_uniform_color(e_uniform.BLEND_COLOR, c_white, vis)
		
		var sunres = res_eval(env_sky_sun_tex);
		render_apply_res(sunres)
		
		if (sunres.type = e_res_type.PACK)
			render_set_texture(sunres.sun_texture)
		else
			render_set_texture(sunres.texture)
			
		var sca = (dis / 15000) * 1850;
		vbuffer_render_matrix(env_sky_sun_moon_vbuffer, matrix_multiply(matrix_build(0, 0, min(dis * 0.7, max(0, (dis * 0.7) / env_sky_sun_scale)), 90, 0, 0 + env_sky_sun_angle, sca * min(1, env_sky_sun_scale), sca * min(1, env_sky_sun_scale), sca), skymat))
		
		// Moon
		vis = percent(vec3_dot(env_sun_direction, vec3(0, 0, -1)), -0.15, 0)
		
		render_set_uniform_color(e_uniform.BLEND_COLOR, c_white, vis)
		
		var moonres = res_eval(env_sky_moon_tex);
		render_apply_res(moonres)
		
		if (moonres.type = e_res_type.PACK && moonres.ready)
		{
			var phase = env_sky_moon_phase;
			render_set_texture(moonres.moon_textures[phase])
		}
		else
			render_set_texture(moonres.texture)
			
		vbuffer_render_matrix(env_sky_sun_moon_vbuffer, matrix_multiply(matrix_build(0, 0, max(-dis * 0.7, min(0, (-dis * 0.7) / env_sky_moon_scale)), -90, 0, 0 - env_sky_moon_angle, sca * min(1, env_sky_moon_scale), sca * min(1, env_sky_moon_scale), sca), skymat))
		
		gpu_set_blendmode(bm_normal)
	}
	
	// Clear shader
	with (render_shader_obj)
		shader_clear()
	gpu_set_zwriteenable(true)
	
	render_alpha_hash = hashprev
	render_set_uniform_int(e_uniform.ALPHA_HASH, render_alpha_hash)
}
