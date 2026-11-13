function tab_properties_project()
{
	// Project name
	tab.project.tbx_name.text = project_name
	tab_control_textfield()
	if (draw_textfield("project/name", dx, dy, dw, 24, tab.project.tbx_name, null, "", "top"))
	{
		project_changed = true
		project_name = tab.project.tbx_name.text
	}
	tab_next()
	
	// Project author
	tab.project.tbx_author.text = project_author
	tab_control_textfield()
	if (draw_textfield("project/author", dx, dy, dw, 24, tab.project.tbx_author, null, "", "top"))
	{
		project_changed = true
		project_author = tab.project.tbx_author.text
	}
	tab_next()
	
	// Project description
	tab.project.tbx_description.text = project_description
	tab_control_textfield(true, 76)
	if (draw_textfield("project/description", dx, dy, dw, 76, tab.project.tbx_description, null, "", "top"))
	{
		project_changed = true
		project_description = tab.project.tbx_description.text
	}
	tab_next()
	
	// Project location
	var directory = "../" + directory_name(project_folder) + filename_name(filename_dir(project_file));
	
	tab_control(40)
	draw_label_value(dx, dy, dw - 28, 40, text_get("new_project/location"), directory, true)
	if (draw_button_icon("new_project/change_folder", dx + dw - 24, dy + 8, 24, 24, false, icons.FOLDER, null, false, "tooltip/open_folder"))
		action_toolbar_open_folder()
	tab_next()
	
	// Video size
	if (project_video_template = 0)
		content_text = text_get("project/video_size_custom")
	else
		content_text = text_get("project/video_size_template/" + project_video_template.name) + " (" + string(project_video_template.width) + "x" + string(project_video_template.height) + ")"
	
	tab_control_menu()
	draw_button_menu("project/video_size", e_menu.LIST, dx, dy, dw, 24, project_video_template, content_text, action_project_video_template)
	tab_next()
	
	// Custom size
	if (project_video_template = 0)
	{
		textfield_group_add("project/video_size_custom_width", project_video_width, 1280, action_project_video_width, X, tab.project.tbx_video_size_custom_width, null, 1, 1, surface_get_max_size())
		textfield_group_add("project/video_size_custom_height", project_video_height, 720, action_project_video_height, X, tab.project.tbx_video_size_custom_height, null, 1, 1, surface_get_max_size())
		
		tab_control_textfield_group()
		draw_textfield_group("project/video_size_custom", dx, dy, dw, 1, 1, no_limit, 1)
		tab_next()
		
		tab_control_switch()
		draw_switch("project/video_size_custom_keep_aspect_ratio", dx, dy, project_video_keep_aspect_ratio, action_project_video_keep_aspect_ratio)
		tab_next()
		
		dy += 8
	}
	
	// Tempo
	tab_control_meter()
	draw_meter("project/tempo", dx, dy, dw, project_tempo, 1, 120, 24, 1, tab.project.tbx_tempo, action_project_tempo, "project/tempo_tip")
	tab_next()

	// Resource pack
	var packfilename = "";
	if (project_pack != mc_res)
		packfilename = project_pack.filename

	tab_control_menu(ui_large_height)
	draw_button_menu("project/pack", e_menu.LIST, dx, dy, dw, ui_large_height, packfilename, project_pack.display_name, action_project_pack, false, project_pack.block_preview_texture)
	tab_next()

	// Renderer settings
	tab_control_switch()
	draw_edit_button("project/edit_render_settings", dx, dy, renderer_settings.show, tab_toggle, renderer_settings, "project/edit_render_settings_tip")
	tab_next()
}
