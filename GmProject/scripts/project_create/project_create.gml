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
	
	project_name = popup_newproject.tbx_name.text
	project_author = popup_newproject.tbx_author.text
	project_description = popup_newproject.tbx_description.text
	
	project_folder = dirname
	project_file = project_folder + "/" + filename_get_valid(project_name) + ".miproject"
	
	popup_close()
	
	// Add the selected resource pack to the new project
	if (popup = popup_newproject && setting_project_pack != "")
	{
		var packfn = packs_directory_get() + setting_project_pack;
		if (file_exists_lib(packfn))
		{
			var packres = new_res(packfn, e_res_type.PACK)
			packres.loaded = true
			with (packres)
				res_load()
		
			action_project_pack(packres)
		}
	}
	project_save()
	
	toast_new(e_toast.POSITIVE, text_get("alertprojectcreated"))
	toast_add_action("alertprojectcreatedview", popup_open_url, project_folder)
	toast_last.dismiss_time = 10
}
