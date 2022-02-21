/// action_project_render_settings(file)
/// @arg file

function action_project_render_settings(file)
{
	if (history_undo)
	{
		file = history_data.oldval
		
		if (history_data != null)
			history_copy_render_settings(history_data.save_obj_old)
	}
	else if (history_redo)
	{
		file = history_data.newval
		
		if (history_data != null)
			history_copy_render_settings(history_data.save_obj_new)
	}
	else
	{
		// Need "Full" version to load custom settings
		if (file != "default" && trial_version)
		{
			popup_show(popup_upgrade)
			popup_upgrade.page = 2
			popup_upgrade.custom_rendering = file
			
			return 0
		}
		
		var hobj = history_set(action_project_render_settings);
		hobj.oldval = project_render_settings
		hobj.newval = file
		hobj.save_obj_new = null
		hobj.save_obj_old = null
	}
	
	project_render_settings = file
	
	if (project_render_settings = "")
		properties.render.enabled = true
	else
	{
		properties.render.enabled = false
		properties.render.show = false
		
		// Load file
		if (!history_redo && !history_undo)
			action_project_render_import(render_directory + project_render_settings + ".mirender")
	}
}
