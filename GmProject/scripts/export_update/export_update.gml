/// export_update()

function export_update()
{
	// Stop?
	if (keyboard_check(vk_escape) && export_escape_time = 0)
		export_escape_time = current_time
	
	// Stop!
	if (export_escape_time > 0 && current_time - export_escape_time > 1000)
	{
		export_escape_time = 0
		if (question(text_get("questionstoprender")))
		{
			if (window_state = "export_movie")
				export_done_movie(true)
			else if (window_state = "export_image")
			{
				surface_save_lib(export_surface, export_filename)
				export_done_image()
			}
			
			return 0
		}
	}
	
	// Update movie
	if (window_state = "export_movie")
	{
		if (render_samples = -1)
		{
			// Update marker
			timeline_marker = exportmovie_marker_start + (exportmovie_frame / popup_exportmovie.framespersecond) * project_tempo
			if (timeline_marker > exportmovie_marker_end)
			{
				export_done_movie()
				return 0
			}
			
			// Update animations
			app_update_animate()
		}
	}
	
	if (window_state = "export_image")
		app_update_cameras(popup_exportimage.high_quality, false)
	
	// Render
	if (window_state = "export_movie")
	{
		render_active = "movie"
		render_quality = (exportmovie_high_quality ? e_view_mode.RENDER : e_view_mode.SHADED)
	}
	else
	{
		render_active = "image"
		render_quality = (popup_exportimage.high_quality ? e_view_mode.RENDER : e_view_mode.SHADED)
	}
	
	if (window_state = "export_movie" && exportmovie_format = "png")
		render_start(export_surface, timeline_camera)
	else
		render_start(export_surface, timeline_camera, project_video_width, project_video_height)
	
	if (render_quality = e_view_mode.RENDER)
		render_high()
	else
	{
		render_low()
		render_samples_done = true
	}
	
	export_surface = render_done()
	
	export_sample++
	
	if (render_quality = e_view_mode.RENDER && render_samples = app.project_render_samples)
		render_samples_done = true
	
	if (!render_samples_done)
		return 1
	
	render_active = null
	render_samples = -1
	
	// Save movie frame
	if (window_state = "export_movie")
	{
		if (exportmovie_format = "png")
		{
			// Save image
			var totalframes = ceil(((exportmovie_marker_end - exportmovie_marker_start) / project_tempo) * popup_exportmovie.framespersecond);
			var totallen = string_length(string(totalframes));
			var numstr = string(exportmovie_frame + 1);
			numstr = string_repeat("0", (totallen - string_length(numstr))) + numstr
			surface_save_lib(export_surface, filename_new_ext(export_filename, "") + "_" + numstr + ".png")
		}
		else
		{
			// Save to movie
			if (!is_cpp())
			{
				buffer_get_surface(exportmovie_buffer, export_surface, 0)
				buffer_save(exportmovie_buffer, temp_file)
			}
		
			var err = movie_frame(temp_file);
			if (err < 0)
			{
				export_done_movie()
				log("Error when adding frame, error code", err)
				error("errorexportmovie")
				return 0
			}
		}
	
		// Advance
		exportmovie_frame++
		current_step += round(60 / popup_exportmovie.framespersecond)
	}
	
	// Save image
	if (window_state = "export_image")
	{
		surface_save_lib(export_surface, export_filename)
		export_done_image()
	}
	
	return 1
}
