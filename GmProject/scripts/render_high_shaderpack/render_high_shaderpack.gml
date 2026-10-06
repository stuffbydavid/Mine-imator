/// render_high_shaderpack()
/// @desc Renders the scene through the loaded shaderpack into render_target.

function render_high_shaderpack()
{
	var starttime = current_time;
	render_surface_time = 0
	
	// Camera matrices for detecting changes
	render_world_start()
	render_world_done()
	
	var refresh = (render_samples = -1 || !render_samples_done || !matrix_equals(render_matrix, view_proj_matrix) ||
				   render_target_size[X] != render_width || render_target_size[Y] != render_height ||
				   !surface_exists(render_shaderpack_surface));
	
	if (refresh)
	{
		render_matrix = array_copy_1d(view_proj_matrix)
		render_target_size = point2D(render_width, render_height)
		
		render_shaderpack_surface = surface_require(render_shaderpack_surface, render_width, render_height)
		
		// Record the scene geometry
		shaderpack_frame_begin(cam_from, cam_to, cam_up, cam_fov, cam_near, cam_far, background_sky_time, background_sky_rotation, background_time, render_width, render_height)
		shaderpack_set_environment(background_sky_color_final, background_fog_color_final, 0, 0, background_sky_moon_phase)
		
		var suntex, moontex, moongrid;
		suntex = null
		moontex = null
		moongrid = false
		if (background_sky_sun_tex != null)
			suntex = (background_sky_sun_tex.type = e_res_type.PACK ? background_sky_sun_tex.sun_texture : background_sky_sun_tex.texture)
		if (background_sky_moon_tex != null)
		{
			if (background_sky_moon_tex.type = e_res_type.PACK && background_sky_moon_tex.ready)
				moontex = background_sky_moon_tex.moon_texture[background_sky_moon_phase]
			else
				moontex = background_sky_moon_tex.texture
		}
		shaderpack_set_sky_textures(sprite_exists(suntex) ? sprite_get_texture(suntex, 0) : 0, sprite_exists(moontex) ? sprite_get_texture(moontex, 0) : 0, moongrid)
		
		render_world_start()
		render_world(e_render_mode.SHADERPACK)
		render_world_done()
		
		// Render, repeated for packs with temporal effects
		var iterations = 1;
		if (render_active = "image" || render_active = "movie")
			iterations = max(1, project_render_shaderpack_warmup)
		else
			iterations = max(1, min(project_render_shaderpack_warmup, 4))
		
		if (!shaderpack_frame_end(render_shaderpack_surface, iterations))
			log("Shaderpack render error", shaderpack_get_error())
		
		render_samples = app.project_render_samples
		render_samples_done = true
	}
	
	// Output
	render_target = surface_require(render_target, render_width, render_height)
	surface_set_target(render_target)
	{
		draw_clear_alpha(c_black, 0)
		gpu_set_blendmode_ext(bm_one, bm_zero)
		draw_surface_exists(render_shaderpack_surface, 0, 0)
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	render_samples_clear = false
	render_time = current_time - starttime - render_surface_time
}
