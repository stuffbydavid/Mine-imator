/// project_create()
/// @desc Creates a new project from the newproject dialog settings.

function project_create()
{
	var dirname = setting_project_folder + popup_newproject.folder;
	
	directory_create_lib(setting_project_folder)
	directory_create_lib(dirname)
	
	if (!directory_exists_lib(dirname))
	{
		error("errornewprojectaccess")
		return 0
	}
	
	log("Creating project", dirname)
	
	project_reset()
	action_load_render_settings(render_default_file)
	
	project_name = popup_newproject.tbx_name.text
	project_author = popup_newproject.tbx_author.text
	project_description = popup_newproject.tbx_description.text
	
	project_folder = dirname
	project_file = project_folder + "/" + filename_get_valid(project_name) + ".miproject"
	
	popup_close()
	
	project_save()
	
	toast_new(e_toast.POSITIVE, text_get("alertprojectcreated"))
	toast_add_action("alertprojectcreatedview", popup_open_url, project_folder)
}
