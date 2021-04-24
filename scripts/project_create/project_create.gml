/// project_create()
/// @desc Creates a new project from the newproject dialog settings.

function project_create()
{
	var dirname = setting_project_folder + popup_newproject.folder;
	
	if (popup_newproject.folder = "")
	{
		error("errornewprojectinvalid")
		return 0
	}
	
	if (directory_exists_lib(setting_project_folder + popup_newproject.folder))
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
	
	log("Creating project", dirname)
	
	project_reset()
	
	project_name = popup_newproject.tbx_name.text
	
	project_folder = dirname
	project_file = project_folder + "\\" + filename_get_valid(project_name) + ".miproject"
	
	popup_close()
	
	project_save()
	
	toast_new(e_toast.POSITIVE, text_get("alertprojectcreated"))
	toast_add_action("alertprojectcreatedview", open_url, project_folder)
}
