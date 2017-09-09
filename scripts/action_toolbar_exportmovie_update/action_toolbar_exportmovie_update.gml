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
render_start(exportmovie_surface, timeline_camera)

if (exportmovie_high_quality)
	render_high()
else
	render_low()
exportmovie_surface = render_done()

if (exportmovie_format = "png")
{
	// Save image
	surface_save_lib(exportmovie_surface, filename_new_ext(exportmovie_filename, "") + "_" + string(exportmovie_frame + 1) + ".png")
}
else
{
	// Save to movie
	buffer_get_surface(exportmovie_buffer, exportmovie_surface, 0, 0, 0)
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
