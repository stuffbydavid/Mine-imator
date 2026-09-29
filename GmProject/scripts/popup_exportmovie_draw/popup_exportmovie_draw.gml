function popup_exportmovie_draw()
{
	// Renderer
	tab_control_menu()
	draw_button_menu("exportmovierenderer", e_menu.LIST, dx, dy, dw, 24, popup_current.renderer, text_get("renderrenderer" + renderer_name_list[popup_current.renderer]), action_toolbar_export_renderer)
	tab_next()

	// Performance warning
	if (popup_current.renderer = e_renderer.REALISTIC)
	{
		var preset = render_preset_map[?project_render_preset[e_renderer.REALISTIC]];
		if (render_performance_warning(preset, e_renderer.REALISTIC))
			draw_tooltip_label("exportmovieperformancewarning", icons.WARNING_TRIANGLE, e_toast.WARNING)
	}

	// Video size
	if (project_video_template = 0)
		content_text = text_get("projectvideosizecustom")
	else
		content_text = text_get("projectvideosizetemplate" + project_video_template.name) + " (" + string(project_video_template.width) + "x" + string(project_video_template.height) + ")"
	
	tab_control_menu()
	draw_button_menu("exportmovievideosize", e_menu.LIST, dx, dy, dw, 24, project_video_template, content_text, action_project_video_template)
	tab_next()
	
	var badvideosize = (popup_current.format = "mp4" || popup_current.format = "mov") && (project_video_width mod 2 = 1 || project_video_height mod 2 = 1);
	
	// Custom
	if (project_video_template = 0)
	{
		textfield_group_add("exportmovievideosizecustomwidth", project_video_width, 1280, action_project_video_width, X, popup_current.tbx_video_size_custom_width, null, 1, (popup_current.format = "mp4" || popup_current.format = "mov") ? 2 : 1, surface_get_max_size())
		textfield_group_add("exportmovievideosizecustomheight", project_video_height, 720, action_project_video_height, X, popup_current.tbx_video_size_custom_height, null, 1, (popup_current.format = "mp4" || popup_current.format = "mov") ? 2 : 1, surface_get_max_size())
		
		tab_control_textfield_group()
		draw_textfield_group("exportmovievideosizecustom", dx, dy, dw, 1, (popup_current.format = "mp4" || popup_current.format = "mov") ? 2 : 1, no_limit, (popup_current.format = "mp4" || popup_current.format = "mov") ? 2 : 1)
		tab_next()
		
		if (badvideosize)
			draw_tooltip_label("exportmovievideosizecustomerror", icons.WARNING_TRIANGLE, e_toast.NEGATIVE)
		
		tab_control_switch()
		draw_switch("exportmovievideosizecustomkeepaspectratio", dx, dy, project_video_keep_aspect_ratio, action_project_video_keep_aspect_ratio)
		tab_next()
		
		dy += 8
	}
	
	// Format
	tab_control_menu()
	draw_button_menu("exportmovieformat", e_menu.LIST, dx, dy, dw, 24, popup_current.format, text_get("exportmovieformat" + popup_current.format), action_toolbar_exportmovie_format)
	tab_next()
	
	// Frame rate
	if (popup_current.frame_rate = 0)
		content_text = text_get("exportmovieframeratecustom")
	else
		content_text = string(popup_current.frame_rate)
	
	tab_control_menu()
	draw_button_menu("exportmovieframerate", e_menu.LIST, dx, dy, dw, 24, popup_current.frame_rate, content_text, action_toolbar_exportmovie_frame_rate)
	tab_next()
	
	if (popup_current.frame_rate = 0)
	{
		tab_control_dragger()
		draw_dragger("exportmovieframespersecond", dx, dy, dragger_width, popup_current.framespersecond, 1, 1, 120, 30, 1, popup_current.tbx_framespersecond, action_toolbar_exportmovie_framespersecond)
		tab_next()
	}
	
	if (popup_current.format = "png")
	{
		// Remove background
		tab_control_checkbox()
		draw_checkbox("exportmovieremovebackground", dx, dy, popup_current.remove_background, action_toolbar_export_remove_background)
		tab_next()
		
		if (popup_current.remove_background)
			draw_tooltip_label("exportimageblendmodewarning", icons.WARNING_TRIANGLE, e_toast.WARNING)
	}
	else
	{
		// Include audio
		tab_control_checkbox()
		draw_checkbox("exportmovieincludeaudio", dx, dy, popup_current.include_audio, action_toolbar_exportmovie_include_audio)
		tab_next()
	}
	
	// Include hidden
	tab_control_checkbox()
	draw_checkbox("exportmovieincludehidden", dx, dy, popup_current.include_hidden, action_toolbar_export_include_hidden)
	tab_next()
	
	// Watermark
	tab_control_checkbox()
	draw_checkbox("exportmoviewatermark", dx, dy, popup_current.watermark, action_toolbar_export_watermark)
	tab_next()
	
	// Save
	tab_control_button_label()
	draw_button_label("exportmoviesave", dx + dw, dy, null, icons.SAVE, e_button.PRIMARY, action_toolbar_exportmovie_save, e_anchor.RIGHT, badvideosize)
	tab_next()
}
