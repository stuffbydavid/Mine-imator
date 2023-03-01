/// popup_exportimage_draw()

function popup_exportimage_draw()
{
	// Video size
	if (project_video_template = 0)
		text = text_get("projectvideosizecustom")
	else
		text = text_get("projectvideosizetemplate" + project_video_template.name) + " (" + string(project_video_template.width) + "x" + string(project_video_template.height) + ")"
	
	tab_control_menu()
	draw_button_menu("exportimageimagesize", e_menu.LIST, dx, dy, dw, 24, project_video_template, text, action_project_video_template)
	tab_next()
	
	// Custom
	if (project_video_template = 0)
	{
		textfield_group_add("exportimageimagesizecustomwidth", project_video_width, 1280, action_project_video_width, X, popup.tbx_image_size_custom_width, null, 1, 1, surface_get_max_size())
		textfield_group_add("exportimageimagesizecustomheight", project_video_height, 720, action_project_video_height, X, popup.tbx_image_size_custom_height, null, 1, 1, surface_get_max_size())
		
		tab_control_textfield_group(false)
		draw_textfield_group("exportimageimagesizecustom", dx, dy, dw, 1, 1, no_limit, 1, false)
		tab_next()
		
		tab_control_switch()
		draw_switch("exportimageimagesizecustomkeepaspectratio", dx, dy, project_video_keep_aspect_ratio, action_project_video_keep_aspect_ratio)
		tab_next()
		
		dy += 8
	}
	
	// Remove background
	tab_control_checkbox()
	draw_checkbox("exportimageremovebackground", dx, dy, popup.remove_background, action_toolbar_exportimage_remove_background)
	tab_next()
	
	if (popup.remove_background)
		draw_tooltip_label("exportimageblendmodewarning", icons.WARNING_TRIANGLE, e_toast.WARNING)
	
	// Include hidden
	tab_control_checkbox()
	draw_checkbox("exportimageincludehidden", dx, dy, popup.include_hidden, action_toolbar_exportimage_include_hidden)
	tab_next()
	
	// High quality
	tab_control_checkbox()
	draw_checkbox("exportimagehighquality", dx, dy, popup.high_quality, action_toolbar_exportimage_high_quality)
	tab_next()
	
	// Watermark
	tab_control_checkbox()
	draw_checkbox("exportimagewatermark", dx, dy, popup.watermark, action_toolbar_exportimage_watermark)
	tab_next()
	
	// Save
	tab_control_button_label()
	draw_button_label("exportimagesave", dx + dw, dy, null, icons.SAVE, e_button.PRIMARY, action_toolbar_exportimage_save, e_anchor.RIGHT)
	tab_next()
}
