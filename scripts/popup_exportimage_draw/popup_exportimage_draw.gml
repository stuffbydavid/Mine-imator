/// popup_exportimage_draw()

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
	tab_control_dragger()
	draw_dragger("exportimageimagesizecustomwidth", dx, dy, dragger_width, project_video_width, 1, 1, no_limit, 1280, 1, popup.tbx_video_size_custom_width, action_project_video_width)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("exportimageimagesizecustomheight", dx, dy, dragger_width, project_video_height, 1, 1, no_limit, 720, 1, popup.tbx_video_size_custom_height, action_project_video_height)
	tab_next()
	
	tab_control_switch()
	draw_switch("exportimageimagesizecustomkeepaspectratio", dx, dy, project_video_keep_aspect_ratio, action_project_video_keep_aspect_ratio)
	tab_next()
}

// Remove background
tab_control_switch()
draw_switch("exportimageremovebackground", dx, dy, popup.remove_background, action_toolbar_exportimage_remove_background)
tab_next()

if (popup.remove_background)
	draw_tooltip_label("exportimageblendmodewarning", icons.WARNING_TRIANGLE, e_toast.WARNING)

// Include hidden
tab_control_switch()
draw_switch("exportimageincludehidden", dx, dy, popup.include_hidden, action_toolbar_exportimage_include_hidden)
tab_next()

// High quality
tab_control_switch()
draw_switch("exportimagehighquality", dx, dy, popup.high_quality, action_toolbar_exportimage_high_quality)
tab_next()

// Save
tab_control_button_label()
draw_button_label("exportimagesave", dx + dw, dy_start + dh - 32, null, icons.SAVE, e_button.PRIMARY, action_toolbar_exportimage_save, e_anchor.RIGHT)
tab_next()
