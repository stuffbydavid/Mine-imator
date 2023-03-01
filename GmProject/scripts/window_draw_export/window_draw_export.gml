/// window_draw_export()

function window_draw_export()
{
	var totalframes, totalsamples, usesamples, perc;
	var framex, framey, framew, frameh;
	var timeleftsecs, timeleftmins, timelefthours, timeleftstr;
	
	// Update rendering
	if (!export_update())
		return 0
	
	// Set dimensions
	if (window_state = "export_movie")
	{
		usesamples = popup_exportmovie.high_quality
		totalframes = ceil(((exportmovie_marker_end - exportmovie_marker_start) / project_tempo) * popup_exportmovie.frame_rate)
		if (usesamples)
			totalsamples = totalframes * project_render_samples
		else
			totalsamples = totalframes
	}
	else
	{
		usesamples = popup_exportimage.high_quality
		if (usesamples)
			totalframes = project_render_samples
		else
			totalframes = 1
		totalsamples = totalframes
	}
	
	perc = export_sample / totalsamples
	
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
	timeleftsecs = max(0, ceil((exportmovie_start + (current_time - exportmovie_start) / perc - current_time) / 1000))
	timeleftmins = timeleftsecs div 60
	timelefthours = timeleftmins div 60
	timeleftsecs = timeleftsecs mod 60
	timeleftmins = timeleftmins mod 60
	
	timeleftstr = ""
	if (timelefthours > 0)
		timeleftstr += text_get(((timelefthours = 1) ? "exporttimelefthour" : "exporttimelefthours"), string(timelefthours)) + ", "
	if (timeleftmins > 0)
		timeleftstr += text_get(((timeleftmins = 1) ? "exporttimeleftminute" : "exporttimeleftminutes"), string(timeleftmins)) + " " + text_get("exporttimeleftand") + " "
	timeleftstr += text_get(((timeleftsecs = 1) ? "exporttimeleftsecond" : "exporttimeleftseconds"), string(timeleftsecs))
	
	draw_label(text_get("exporttimeleft", timeleftstr), framex + framew / 2, framey + frameh + 33, fa_center, fa_bottom, c_text_secondary, a_text_secondary, font_label_big)
	
	// Bar
	var loadtext, loadw, sw, sh;
	loadtext = text_get("exportloading", string(floor(perc * 100)))
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
	if (usesamples)
		samplecount = text_get("exportsamples", string(max(render_samples, 1)), string(project_render_samples))
	var text = "";
	
	if (window_state = "export_movie")
		text = text_get("exportframe", string(exportmovie_frame), string(totalframes)) + (usesamples ? (" (" + samplecount + ")") : "")
	else if (usesamples)
		text = samplecount
	
	draw_loading_bar((framex + framew/2) - loadw/2, framey + frameh + 40, loadw, 8, perc, text, "")
	
	window_set_caption(loadtext + " - Mine-imator")
	
	// Title
	draw_label(window_state = "export_movie" ? text_get("exportmovietitle") : text_get("exportimagetitle"), framex + framew / 2, framey - 35, fa_center, fa_bottom, c_accent, 1, font_heading_big)
	
	// Stop
	draw_label(text_get("exportstop"), framex + framew / 2, framey - 16, fa_center, fa_bottom, c_text_tertiary, a_text_tertiary, font_caption)
}
