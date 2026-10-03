/// @desc Settings for starting a new project.

function popup_newproject_draw()
{
	var issue = false;
	
	if (popup_current.folder = "" || directory_exists_lib(setting_project_folder + popup_current.folder))
		issue = true
	
	// Project name
	tab_control_textfield(true)
	if (draw_textfield("new_project/name", dx, dy, dw, 24, popup_current.tbx_name, null, popup_current.folder, "top") || issue)
	{
		popup_current.folder = filename_get_valid(popup_current.tbx_name.text)
		
		if (popup_current.folder = "")
			popup_current.folder = text_get("new_project/name_default")
		
		popup_current.folder = filename_name(filename_get_unique(setting_project_folder + popup_current.folder))
	}
	tab_next()
	
	// Project author
	tab_control_textfield(true)
	if (draw_textfield("new_project/author", dx, dy, dw, 24, popup_current.tbx_author, null, "", "top"))
	{
		popup_current.author = popup_current.tbx_author.text
	}
	tab_next()
	
	// Project description
	tab_control_textfield(true, 76)
	if (draw_textfield("new_project/description", dx, dy, dw, 76, popup_current.tbx_description, null, "", "top"))
	{
		popup_current.description = popup_current.tbx_description.text
	}
	tab_next()

	// Project location
	var dir = "../" + directory_name(setting_project_folder) + string_remove_newline(popup_current.folder);
	
	tab_control(40)
	draw_label_value(dx, dy, dw - 28, 40, text_get("new_project/location"), dir, true)
	if (draw_button_icon("new_project/change_folder", dx + dw - 24, dy + 8, 24, 24, false, icons.FOLDER_EDIT, null, false, "tooltip/change_folder"))
	{
		var fn = file_dialog_save_project(popup_current.folder);
		if (fn != "")
		{
			popup_current.folder = filename_name(fn)
			action_setting_project_folder(filename_path(fn))
		}
	}
	tab_next()

	// Project pack
	var projectpack, packpreview;
	projectpack = mc_res.display_name
	packpreview = mc_res.block_preview_texture
	
	if (setting_project_pack != "")
	{
		projectpack = setting_project_pack
		packpreview = minecraft_get_pack_image(setting_project_pack)
	}

	tab_control_menu(ui_large_height)
	draw_button_menu("new_project/pack", e_menu.LIST, dx, dy, dw, ui_large_height, setting_project_pack, projectpack, action_setting_project_pack, false, packpreview)
	tab_next()
	
	// Create
	tab_control_button_label()
	if (draw_button_label("new_project/create", dx + dw, dy, null, null, e_button.PRIMARY, null, e_anchor.RIGHT))
	{
		if (window_state = "startup")
			window_state = ""
		
		popup_switch_to = null
		project_create()
	}
	tab_next()
}
