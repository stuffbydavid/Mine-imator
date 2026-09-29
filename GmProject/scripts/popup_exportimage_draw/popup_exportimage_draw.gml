function popup_exportimage_draw()
{
	// Renderer
	tab_control_menu()
	draw_button_menu("exportimagerenderer", e_menu.LIST, dx, dy, dw, 24, popup_current.renderer, text_get("renderrenderer" + renderer_name_list[popup_current.renderer]), action_toolbar_export_renderer)
	tab_next()
	
	// Video size
	if (project_video_template = 0)
		content_text = text_get("projectvideosizecustom")
	else
		content_text = text_get("projectvideosizetemplate" + project_video_template.name) + " (" + string(project_video_template.width) + "x" + string(project_video_template.height) + ")"
	
	tab_control_menu()
	draw_button_menu("exportimageimagesize", e_menu.LIST, dx, dy, dw, 24, project_video_template, content_text, action_project_video_template)
	tab_next()
	
	// Custom
	if (project_video_template = 0)
	{
		textfield_group_add("exportimageimagesizecustomwidth", project_video_width, 1280, action_project_video_width, X, popup_current.tbx_image_size_custom_width, null, 1, 1, surface_get_max_size())
		textfield_group_add("exportimageimagesizecustomheight", project_video_height, 720, action_project_video_height, X, popup_current.tbx_image_size_custom_height, null, 1, 1, surface_get_max_size())
		
		tab_control_textfield_group()
		draw_textfield_group("exportimageimagesizecustom", dx, dy, dw, 1, 1, no_limit, 1)
		tab_next()
		
		tab_control_switch()
		draw_switch("exportimageimagesizecustomkeepaspectratio", dx, dy, project_video_keep_aspect_ratio, action_project_video_keep_aspect_ratio)
		tab_next()
		
		dy += 8
	}
	
	// Remove background
	tab_control_checkbox()
	draw_checkbox("exportimageremovebackground", dx, dy, popup_current.remove_background, action_toolbar_export_remove_background)
	tab_next()
	
	if (popup_current.remove_background)
		draw_tooltip_label("exportimageblendmodewarning", icons.WARNING_TRIANGLE, e_toast.WARNING)
	
	// Include hidden
	tab_control_checkbox()
	draw_checkbox("exportimageincludehidden", dx, dy, popup_current.include_hidden, action_toolbar_export_include_hidden)
	tab_next()
	
	// Watermark
	tab_control_checkbox()
	draw_checkbox("exportimagewatermark", dx, dy, popup_current.watermark, action_toolbar_export_watermark)
	tab_next()
	
	// Save
	tab_control_button_label()
	draw_button_label("exportimagesave", dx + dw, dy, null, icons.SAVE, e_button.PRIMARY, action_toolbar_exportimage_save, e_anchor.RIGHT)
	tab_next()
}
