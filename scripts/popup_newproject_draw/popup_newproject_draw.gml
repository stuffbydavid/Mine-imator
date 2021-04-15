/// popup_newproject_draw()
/// @desc Settings for starting a new project.

var warntext = "";

if (popup.folder = "")
	warntext = text_get("newprojectnameempty")
else if (directory_exists_lib(setting_project_folder + popup_newproject.folder))
	warntext = text_get("newprojectnameexists")

tab_control_textfield(true)
if (draw_textfield("newprojectname", dx, dy, dw, 24, popup.tbx_name, null, text_get("newprojectname"), "top", warntext != ""))
	popup.folder = filename_get_valid(popup.tbx_name.text)
tab_next()

if (warntext != "")
{
	tab_control(8)
	draw_label(warntext, dx, dy + 8, fa_left, fa_bottom, c_error, 1, font_caption)
	tab_next()
}

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

// Create
tab_control_button_label()
if (draw_button_label("newprojectcreate", dx + dw, dy_start + dh - 32, null, null, e_button.PRIMARY, null, e_anchor.RIGHT, warntext != ""))
{
	if (window_state = "startup")
		window_state = ""
	
	popup_switch_to = null
	project_create()
}
tab_next()
