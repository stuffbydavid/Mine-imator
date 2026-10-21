/// @desc Settings for saving a new project.

function popup_saveas_draw()
{
	var issue = false;
	
	if (popup_current.folder = "" || directory_exists_lib(setting_project_folder + popup_current.folder))
		issue = true
	
	// Project name
	tab_control_textfield(true)
	if (draw_textfield("new_project/name", dx, dy, dw, 24, popup_current.tbx_name, null, text_get("save_as/copy", project_name), "top") || issue)
	{
		popup_current.folder = filename_get_valid(popup_current.tbx_name.text)
		
		if (popup_current.folder = "")
			popup_current.folder = text_get("save_as/copy", project_name)
		
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
	if (draw_button_icon("new_project/change_folder", dx + dw - 24, dy + 8, 24, 24, false, icons.FOLDER_EDIT, null, null, "tooltip/change_folder"))
	{
		var fn = file_dialog_save_project(popup_current.folder);
		if (fn != "")
		{
			popup_current.folder = filename_name(fn)
			action_setting_project_folder(filename_path(fn))
		}
	}
	tab_next()
	
	// Save
	tab_control_button_label()
	if (draw_button_label("save_as/save", dx + dw, dy, null, icons.SAVE, e_button.PRIMARY, null, e_anchor.RIGHT))
		project_save_as()
	tab_next()
}
