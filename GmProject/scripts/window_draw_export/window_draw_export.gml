function window_draw_export()
{
	// Update rendering
	if (!export_update())
		return 0
	
	var totalframes, totalsamples, usesamples, perc;
	var framex, framey, framew, frameh;
	var timeleftsecs, timeleftmins, timelefthours, timeleftstr;
	
	// Set dimensions
	if (window_state = "export_movie")
	{
		usesamples = (exportmovie_renderer = e_renderer.REALISTIC)
		totalframes = ceil(((exportmovie_marker_end - exportmovie_marker_start) / project_tempo) * popup_exportmovie.framespersecond)
		if (usesamples)
			totalsamples = totalframes * project_render_samples
		else
			totalsamples = totalframes
	}
	else
	{
		usesamples = popup_exportimage.renderer = e_renderer.REALISTIC
		if (usesamples)
			totalframes = project_render_samples
		else
			totalframes = 1
		totalsamples = totalframes
	}
	
	perc = export_sample / totalsamples
	window_taskbar_progress_value_set(perc)
	
	content_width = floor(window_width * 0.5)
	content_height = min(500, floor(window_height * 0.5))
	content_x = floor(window_width / 2 - content_width / 2)
	content_y = floor(window_height / 2 - content_height / 2)
	
	// Background
	draw_clear(c_level_middle)
	draw_pattern(0, 0, window_width, window_height)
	
	// Current surface
	framew = content_width
	frameh = content_height
	framex = floor(window_width/2 - framew/2)
	framey = floor(window_height/2 - frameh/2)
	
	gpu_set_tex_filter(true)
	draw_surface_box_center(export_surface, framex, framey, framew, frameh)
	gpu_set_tex_filter(false)
	
	content_width = window_width
	content_height = window_height
	
	// Time left
	if (window_state != "export_movie" || exportmovie_frame > 0)
	{
		if (window_state = "export_movie")
			timeleftsecs = max(0, ceil(((exportmovie_frame_last_time - exportmovie_start) / exportmovie_frame) * (totalframes - exportmovie_frame) / 1000000))
		else
			timeleftsecs = max(0, ceil((exportmovie_start + (get_timer() - exportmovie_start) / perc - get_timer()) / 1000000))
		timeleftmins = timeleftsecs div 60
		timelefthours = timeleftmins div 60
		timeleftsecs = timeleftsecs mod 60
		timeleftmins = timeleftmins mod 60

		timeleftstr = ""
		if (timelefthours > 0)
			timeleftstr += text_get(((timelefthours = 1) ? "export_movie/time_left/hour" : "export_movie/time_left/hours"), string(timelefthours)) + ", "
		if (timeleftmins > 0)
			timeleftstr += text_get(((timeleftmins = 1) ? "export_movie/time_left/minute" : "export_movie/time_left/minutes"), string(timeleftmins)) + " " + text_get("export_movie/time_left/and") + " "
		timeleftstr += text_get(((timeleftsecs = 1) ? "export_movie/time_left/second" : "export_movie/time_left/seconds"), string(timeleftsecs))

		draw_label(text_get("export_movie/time_left", timeleftstr), framex + framew / 2, framey + frameh + 33, fa_center, fa_bottom, c_text_secondary, a_text_secondary, font_heading_big)
	}
	
	// Bar
	var loadtext, loadw, sw, sh;
	loadtext = text_get("export_movie/loading", string(floor(perc * 100)))
	loadw = framew
	sw = surface_get_width(export_surface)
	sh = surface_get_height(export_surface)
	
	// Match frame width
	if (sw / sh < framew / frameh)
	{
		var scale = frameh / sh;
		loadw = floor(sw * scale)
	}
	
	var samplecount = "";
	content_text = ""
	
	if (usesamples)
		samplecount = text_get("export_movie/samples", string(max(render_samples, 1)), string(project_render_samples))
	
	if (window_state = "export_movie")
		content_text = text_get("export_movie/frame", string(exportmovie_frame), string(totalframes)) + (usesamples ? (" (" + samplecount + ")") : "")
	else if (usesamples)
		content_text = samplecount
	
	var samplerate, samplehint;
	samplerate = export_samples_per_second
	if (usesamples && samplerate = 0 && export_sample_rate_count > 0)
		samplerate = export_sample_rate_count * 1000000 / max(1, get_timer() - export_sample_rate_start)
	samplehint = usesamples ? text_get("export_movie/samples_per_second", string_format(samplerate, 0, 1)) : ""
	
	draw_loading_bar((framex + framew/2) - loadw/2, framey + frameh + 40, loadw, 8, perc, content_text, samplehint)
	
	window_set_caption(loadtext + " - Mine-imator")
	
	// Title
	draw_label(window_state = "export_movie" ? text_get("export_movie/title") : text_get("export_image/title"), framex + framew / 2, framey - 35, fa_center, fa_bottom, c_accent, 1, font_heading_big)
	
	// Stop
	draw_label(text_get("export_movie/stop"), framex + framew / 2, framey - 16, fa_center, fa_bottom, c_text_tertiary, a_text_tertiary, font_caption)
}
