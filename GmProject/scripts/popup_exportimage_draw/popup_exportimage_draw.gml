function popup_exportimage_draw()
{
	// Renderer
	tab_control_togglebutton()
	togglebutton_add("render/renderer/quick", icons.CIRCLE_OUTLINE, e_renderer.QUICK, popup_current.renderer = e_renderer.QUICK, action_toolbar_export_renderer)
	togglebutton_add("render/renderer/standard", setting_theme.dark ? icons.SPHERE_SHADING_DARK : icons.SPHERE_SHADING, e_renderer.STANDARD, popup_current.renderer = e_renderer.STANDARD, action_toolbar_export_renderer)
	togglebutton_add("render/renderer/realistic", setting_theme.dark ? icons.SPHERE_MATERIAL_DARK : icons.SPHERE_MATERIAL, e_renderer.REALISTIC, popup_current.renderer = e_renderer.REALISTIC, action_toolbar_export_renderer)
	draw_label(text_get("export_image/renderer"), dx, dy - 3, fa_left, fa_top, c_text_secondary, a_text_secondary, font_label)
	draw_togglebutton("export_image/renderer", dx, dy + label_height + 8, true, false)
	tab_next()
	
	dy += 4
	
	// Video size
	if (project_video_template = 0)
		content_text = text_get("project/video_size_custom")
	else
		content_text = text_get("project/video_size_template/" + project_video_template.name) + " (" + string(project_video_template.width) + "x" + string(project_video_template.height) + ")"
	
	tab_control_menu()
	draw_button_menu("export_image/image_size", e_menu.LIST, dx, dy, dw, 24, project_video_template, content_text, action_project_video_template)
	tab_next()
	
	// Custom
	if (project_video_template = 0)
	{
		textfield_group_add("export_image/image_size_custom_width", project_video_width, 1280, action_project_video_width, X, popup_current.tbx_image_size_custom_width, null, 1, 1, surface_get_max_size())
		textfield_group_add("export_image/image_size_custom_height", project_video_height, 720, action_project_video_height, X, popup_current.tbx_image_size_custom_height, null, 1, 1, surface_get_max_size())
		
		tab_control_textfield_group()
		draw_textfield_group("export_image/imagesizecustom", dx, dy, dw, 1, 1, no_limit, 1)
		tab_next()
		
		tab_control_switch()
		draw_switch("export_image/image_size_custom_keep_aspect_ratio", dx, dy, project_video_keep_aspect_ratio, action_project_video_keep_aspect_ratio)
		tab_next()
		
		dy += 8
	}
	
	// Remove background
	tab_control_checkbox()
	draw_checkbox("export_image/remove_background", dx, dy, popup_current.remove_background, action_toolbar_export_remove_background)
	tab_next()
	
	if (popup_current.remove_background)
		draw_tooltip_label("export_image/blend_mode_warning", icons.WARNING_TRIANGLE, e_toast.WARNING)
	
	// Include hidden
	tab_control_checkbox()
	draw_checkbox("export_image/include_hidden", dx, dy, popup_current.include_hidden, action_toolbar_export_include_hidden)
	tab_next()
	
	// Watermark
	tab_control_checkbox()
	draw_checkbox("export_image/watermark", dx, dy, popup_current.watermark, action_toolbar_export_watermark)
	tab_next()
	
	// Save
	tab_control_button_label()
	draw_button_label("export_image/save", dx + dw, dy, null, icons.SAVE, e_button.PRIMARY, action_toolbar_exportimage_save, e_anchor.RIGHT)
	tab_next()
}
