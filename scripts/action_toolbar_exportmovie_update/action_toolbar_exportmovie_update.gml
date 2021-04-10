/// action_toolbar_exportmovie_update()

// Stop?
if (keyboard_check(vk_escape) && exportmovie_escape_time = 0)
	exportmovie_escape_time = current_time

// Stop!
if (exportmovie_escape_time > 0 && current_time - exportmovie_escape_time > 1000)
{
	exportmovie_escape_time = 0
	if (question(text_get("questionstoprender")))
	{
		action_toolbar_exportmovie_done()
		return 0
	}
}

// Update marker
timeline_marker = exportmovie_marker_start + (exportmovie_frame / popup_exportmovie.frame_rate) * project_tempo
if (timeline_marker > exportmovie_marker_end)
{
	action_toolbar_exportmovie_done()
	return 0
}

// Update animations
app_update_animate()

// Render
render_active = "movie"
render_quality = (exportmovie_high_quality ? e_view_mode.RENDER : e_view_mode.SHADED)

if (exportmovie_format = "png")
	render_start(exportmovie_surface, timeline_camera)
else
	render_start(exportmovie_surface, timeline_camera, project_video_width, project_video_height)

if (exportmovie_high_quality)
	render_high()
else
	render_low()

exportmovie_surface = render_done()

render_active = null

// Free surfaces to prevent memory issues
render_free()

if (exportmovie_format = "png")
{
	// Save image
	var totalframes = ceil(((exportmovie_marker_end - exportmovie_marker_start) / project_tempo) * popup_exportmovie.frame_rate);
	var totallen = string_length(string(totalframes));
	var numstr = string(exportmovie_frame + 1);
	numstr = string_repeat("0", (totallen - string_length(numstr))) + numstr
	surface_save_lib(exportmovie_surface, filename_new_ext(exportmovie_filename, "") + "_" + numstr + ".png")
}
else
{
	// Save to movie
	buffer_get_surface(exportmovie_buffer, exportmovie_surface, 0, 0, 0)
	
	// Surface buffer GM bug
	repeat (buffer_get_size(exportmovie_buffer))
		buffer_write(exportmovie_buffer, buffer_u8, 0)
	
	buffer_save(exportmovie_buffer, temp_file)
	
	var err = movie_frame(temp_file);
	if (err < 0)
	{
		action_toolbar_exportmovie_done()
		log("Error when adding frame, error code", err)
		error("errorexportmovie")
		return 0
	}
}

// Advance
exportmovie_frame++
current_step += round(60 / popup_exportmovie.frame_rate)

return 1
