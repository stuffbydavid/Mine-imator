/// project_save_as()
/// @desc Creates a new project from the saveas dialog settings.

var dirname = setting_project_folder + popup_saveas.folder;

if (popup_saveas.folder = "")
{
	error("errornewprojectinvalid")
	return 0
}

if (directory_exists_lib(setting_project_folder + popup_saveas.folder))
{
	error("errornewprojectexists")
	return 0
}

directory_create_lib(setting_project_folder)
directory_create_lib(dirname)

if (!directory_exists_lib(dirname))
{
	error("errornewprojectaccess")
	return 0
}

log("Saving project as new", dirname)

project_name = popup_saveas.tbx_name.text;
project_author = popup_saveas.tbx_author.text;
project_description = popup_saveas.tbx_description.text;

load_folder = project_folder
project_folder = dirname
project_file = project_folder + "\\" + filename_valid(project_name) + ".mproj"
save_folder = project_folder

with (obj_resource)
	if (id != res_def)
		res_save()

popup_close()

project_save("")

alert_show(text_get("alertprojectsavedtitle"), text_get("alertprojectsaveastext"), 0, "alertprojectcreatedbutton", project_folder, 5000)
