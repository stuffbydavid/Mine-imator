/// window_draw_exportmovie()

function window_draw_exportmovie()
{
	var totalframes, perc;
	var framex, framey, framew, frameh;
	var timeleftsecs, timeleftmins, timelefthours, timeleftstr;
	
	// Update rendering
	if (!action_toolbar_exportmovie_update())
		return 0
	
	// Set dimensions
	totalframes = ceil(((exportmovie_marker_end - exportmovie_marker_start) / project_tempo) * popup_exportmovie.frame_rate)
	perc = exportmovie_frame / totalframes
	
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
	
	//draw_box(framex, framey, framew, frameh, false, c_level_bottom, 1)
	draw_surface_box_center(exportmovie_surface, framex, framey, framew, frameh)
	
	content_width = window_width
	content_height = window_height
	
	// Time left
	timeleftsecs = ceil((exportmovie_start + (current_time - exportmovie_start) / perc - current_time) / 1000)
	timeleftmins = timeleftsecs div 60
	timelefthours = timeleftmins div 60
	timeleftsecs = timeleftsecs mod 60
	timeleftmins = timeleftmins mod 60
	
	timeleftstr = ""
	if (timelefthours > 0)
		timeleftstr += text_get(((timelefthours = 1) ? "exportmovietimelefthour" : "exportmovietimelefthours"), string(timelefthours)) + ", "
	if (timeleftmins > 0)
		timeleftstr += text_get(((timeleftmins = 1) ? "exportmovietimeleftminute" : "exportmovietimeleftminutes"), string(timeleftmins)) + " " + text_get("exportmovietimeleftand") + " "
	timeleftstr += text_get(((timeleftsecs = 1) ? "exportmovietimeleftsecond" : "exportmovietimeleftseconds"), string(timeleftsecs))
	
	draw_label(text_get("exportmovietimeleft", timeleftstr), framex + framew / 2, framey + frameh + 33, fa_center, fa_bottom, c_text_secondary, a_text_secondary, font_label_big)
	
	// Bar
	var loadtext, loadw, sw, sh;
	loadtext = text_get("exportmovieloading", string(floor(perc * 100)))
	loadw = framew
	sw = surface_get_width(exportmovie_surface)
	sh = surface_get_height(exportmovie_surface)
	
	// Match frame width
	if (sw / sh < framew / frameh)
	{
		var scale = frameh / sh;
		loadw = floor(sw * scale)
	}
	
	draw_loading_bar((framex + framew/2) - loadw/2, framey + frameh + 40, loadw, 8, perc, text_get("exportmovieframe", string(exportmovie_frame), string(totalframes)))
	window_set_caption(loadtext + " - Mine-imator")
	
	// Title
	draw_label(text_get("exportmovietitle"), framex + framew / 2, framey - 35, fa_center, fa_bottom, c_accent, 1, font_heading_big)
	
	// Stop
	draw_label(text_get("exportmoviestop"), framex + framew / 2, framey - 16, fa_center, fa_bottom, c_text_tertiary, a_text_tertiary, font_caption)
}
