/// popup_exportmovie_draw()

function popup_exportmovie_draw()
{
	var text;
	
	// Video size
	if (project_video_template = 0)
		text = text_get("projectvideosizecustom")
	else
		text = text_get("projectvideosizetemplate" + project_video_template.name) + " (" + string(project_video_template.width) + "x" + string(project_video_template.height) + ")"
	
	tab_control_menu()
	draw_button_menu("exportmovievideosize", e_menu.LIST, dx, dy, dw, 24, project_video_template, text, action_project_video_template)
	tab_next()
	
	// Custom
	if (project_video_template = 0)
	{
		textfield_group_add("exportmovievideosizecustomwidth", project_video_width, 1280, action_project_video_width, X, popup.tbx_video_size_custom_width, null, 1, 1, surface_get_max_size())
		textfield_group_add("exportmovievideosizecustomheight", project_video_height, 720, action_project_video_height, X, popup.tbx_video_size_custom_height, null, 1, 1, surface_get_max_size())
		
		tab_control_textfield_group(false)
		draw_textfield_group("exportmovievideosizecustom", dx, dy, dw, 1, 1, no_limit, 1, false)
		tab_next()
		
		tab_control_switch()
		draw_switch("exportmovievideosizecustomkeepaspectratio", dx, dy, project_video_keep_aspect_ratio, action_project_video_keep_aspect_ratio)
		tab_next()
		
		dy += 8
	}
	
	// Format
	tab_control_menu()
	draw_button_menu("exportmovieformat", e_menu.LIST, dx, dy, dw, 24, popup.format, text_get("exportmovieformat" + popup.format), action_toolbar_exportmovie_format)
	tab_next()
	
	if (popup.format != "png")
	{
		// Quality
		if (popup.video_quality = 0)
			text = text_get("exportmovievideoqualitycustom")
		else
			text = text_get("exportmovievideoquality" + popup.video_quality.name)
		
		tab_control_menu()
		draw_button_menu("exportmovievideoquality", e_menu.LIST, dx, dy, dw, 24, popup.video_quality, text, action_toolbar_exportmovie_video_quality)
		tab_next()
		
		// Custom quality
		if (popup.video_quality = 0)
		{
			tab_control_dragger()
			draw_dragger("exportmoviebitrate", dx, dy, dragger_width, popup.bit_rate, 500, 1, no_limit, 2500000, 1, popup.tbx_bit_rate, action_toolbar_exportmovie_bit_rate)
			tab_next()
		}
	}
	
	// Frame rate
	if (popup.frame_rate = 0)
		text = text_get("exportmovieframeratecustom")
	else
		text = string(popup.frame_rate)
	
	tab_control_menu()
	draw_button_menu("exportmovieframerate", e_menu.LIST, dx, dy, dw, 24, popup.frame_rate, text, action_toolbar_exportmovie_frame_rate)
	tab_next()
	
	if (popup.frame_rate = 0)
	{
		tab_control_dragger()
		draw_dragger("exportmovieframespersecond", dx, dy, dragger_width, popup.framespersecond, 1, 1, 120, 30, 1, popup.tbx_framespersecond, action_toolbar_exportmovie_framespersecond)
		tab_next()
	}
	
	if (popup.format = "png")
	{
		// Remove background
		tab_control_checkbox()
		draw_checkbox("exportmovieremovebackground", dx, dy, popup.remove_background, action_toolbar_exportmovie_remove_background)
		tab_next()
		
		if (popup.remove_background)
			draw_tooltip_label("exportimageblendmodewarning", icons.WARNING_TRIANGLE, e_toast.WARNING)
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
	
	// Watermark
	tab_control_checkbox()
	draw_checkbox("exportmoviewatermark", dx, dy, popup.watermark, action_toolbar_exportmovie_watermark)
	tab_next()
	
	// Save
	tab_control_button_label()
	draw_button_label("exportmoviesave", dx + dw, dy, null, icons.SAVE, e_button.PRIMARY, action_toolbar_exportmovie_save, e_anchor.RIGHT)
	tab_next()
}
