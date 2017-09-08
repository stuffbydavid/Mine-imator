/// popup_exportmovie_draw()

var capwid, text;

capwid = text_caption_width("exportmovievideosize", "exportmovievideosizecustomwidth", "exportmovieformat", "exportmovievideoquality", "exportmovieframerate")

// Video size
if (project_video_template = 0)
	text = text_get("projectvideosizecustom")
else
	text = project_video_template.name + " (" + string(project_video_template.width) + "x" + string(project_video_template.height) + ")"

tab_control(24)
draw_button_menu("exportmovievideosize", e_menu.LIST, dx, dy, dw, 24, project_video_template, text, action_project_video_template, null, null, capwid)
tab_next()

// Custom
if (project_video_template = 0)
{
	tab_control_dragger()
	draw_dragger("exportmovievideosizecustomwidth", dx, dy, 140, project_video_width, 1, 1, no_limit, 1280, 1, popup.tbx_video_size_custom_width, action_project_video_width, capwid)
	draw_dragger("exportmovievideosizecustomheight", dx + 140, dy, dw - 140, project_video_height, 1, 1, no_limit, 720, 1, popup.tbx_video_size_custom_height, action_project_video_height)
	tab_next()
	tab_control_checkbox()
	draw_checkbox("exportmovievideosizecustomkeepaspectratio", dx, dy, project_video_keep_aspect_ratio, action_project_video_keep_aspect_ratio)
	tab_next()
}

// Format
tab_control(24)
draw_button_menu("exportmovieformat", e_menu.LIST, dx, dy, capwid + 140, 24, popup.format, text_get("exportmovieformat" + popup.format), action_toolbar_exportmovie_format, null, null, capwid)
tab_next()

if (popup.format != "png")
{
	// Quality
	tab_control(24)
	if (popup.video_quality = 0)
		text = text_get("exportmovievideoqualitycustom")
	else
		text = text_get("exportmovievideoquality" + popup.video_quality.name)
	draw_button_menu("exportmovievideoquality", e_menu.LIST, dx, dy, capwid + 140, 24, popup.video_quality, text, action_toolbar_exportmovie_video_quality, null, null, capwid)
	
	// Custom quality
	if (popup.video_quality = 0)
		draw_dragger("exportmoviebitrate", dx + capwid + 140 + 16, dy + 2, 200, popup.bit_rate, 500, 1, no_limit, 2500000, 1, popup.tbx_bit_rate, action_toolbar_exportmovie_bit_rate)
	
	tab_next()
}

// Frame rate
tab_control(24)
draw_button_menu("exportmovieframerate", e_menu.LIST, dx, dy, capwid + 80, 24, popup.frame_rate, string(popup.frame_rate), action_toolbar_exportmovie_frame_rate, null, null, capwid)
tab_next()

dy += 10

if (popup.format = "png") 
{
	// Remove background
	tab_control_checkbox()
	draw_checkbox("exportmovieremovebackground", dx, dy, popup.remove_background, action_toolbar_exportmovie_remove_background)
	tab_next()
}
else
{
	// Include audio
	tab_control_checkbox()
	draw_checkbox("exportmovieincludeaudio", dx, dy, popup.include_audio, action_toolbar_exportmovie_include_audio)
	tab_next()
}

// Include hidden
tab_control_checkbox()
draw_checkbox("exportmovieincludehidden", dx, dy, popup.include_hidden, action_toolbar_exportmovie_include_hidden)
tab_next()

// High quality
tab_control_checkbox()
draw_checkbox("exportmoviehighquality", dx, dy, popup.high_quality, action_toolbar_exportmovie_high_quality)
tab_next()

// Save
dw = 100
dh = 32
dx = content_x + content_width / 2 - dw - 4
dy = content_y + content_height - 32
if (draw_button_normal("exportmoviesave", dx, dy, dw, 32))
	action_toolbar_exportmovie_save()

// Cancel
dx = content_x + content_width / 2 + 4
if (draw_button_normal("exportmoviecancel", dx, dy, dw, 32))
	popup_close()
