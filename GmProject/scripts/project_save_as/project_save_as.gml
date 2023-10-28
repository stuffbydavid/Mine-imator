/// project_save_as()
/// @desc Creates a new project from the saveas dialog settings.

function project_save_as()
{
	var dirname = setting_project_folder + popup_saveas.folder;
	
	directory_create_lib(setting_project_folder)
	directory_create_lib(dirname)
	
	if (!directory_exists_lib(dirname))
	{
		error("errornewprojectaccess")
		return 0
	}
	
	log("Saving project as new", dirname)
	
	project_name = popup_saveas.tbx_name.text
	project_author = popup_saveas.tbx_author.text
	project_description = popup_saveas.tbx_description.text
	
	load_folder = project_folder
	project_folder = dirname
	project_file = project_folder + "/" + filename_get_valid(project_name) + ".miproject"
	save_folder = project_folder
	
	with (obj_resource)
		if (id != mc_res)
			res_save()
	
	popup_close()
	
	project_save()
	
	toast_new(e_toast.POSITIVE, text_get("alertprojectcreated"))
	toast_add_action("alertprojectcreatedview", popup_open_url, project_folder)
}
