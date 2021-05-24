/// popup_saveas_draw()
/// @desc Settings for saving a new project.

function popup_saveas_draw()
{
	var issue = false;
	
	if (popup.folder = "" || directory_exists_lib(setting_project_folder + popup.folder))
		issue = true
	
	tab_control_textfield(true)
	if (draw_textfield("newprojectname", dx, dy, dw, 24, popup.tbx_name, null, text_get("saveascopy", project_name), "top") || issue)
	{
		popup.folder = filename_get_valid(popup.tbx_name.text)
		
		if (popup.folder = "")
			popup.folder = text_get("saveascopy", project_name)
		
		popup.folder = filename_name(filename_get_unique(setting_project_folder + popup.folder))
	}
	tab_next()
	
	// Project location
	tab_control(40)
	draw_label(text_get("newprojectlocation"), dx, dy + 20, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_label)
	
	var directory = "...\\" + directory_name(setting_project_folder) + string_remove_newline(popup.folder);
	
	draw_label(directory, dx, dy + 38, fa_left, fa_bottom, c_text_main, a_text_main, font_value)
	if (draw_button_icon("newprojectchangefolder", dx + dw - 24, dy + 12, 24, 24, false, icons.FOLDER_EDIT, null, null, "tooltipchangefolder"))
	{
		var fn = file_dialog_save_project(popup.folder)
		if (fn != "")
		{
			popup.folder = filename_name(fn)
			action_setting_project_folder(filename_path(fn))
		}
	}
	tab_next()
	
	// Save
	tab_control_button_label()
	if (draw_button_label("saveassave", dx + dw, dy_start + dh - 32, null, null, e_button.PRIMARY, null, e_anchor.RIGHT))
		project_save_as()
	tab_next()
}
