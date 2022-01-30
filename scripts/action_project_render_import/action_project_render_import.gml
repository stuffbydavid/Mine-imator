/// action_project_render_import([fn])
/// @arg [fn]

function action_project_render_import(fn = "")
{
	if (history_undo)
		history_copy_render_settings(history_data.save_obj_old)
	else if (history_redo)
		history_copy_render_settings(history_data.save_obj_new)
	else
	{
		if (fn = "")
			fn = file_dialog_open_render()
		
		if (fn = "")
			return 0
		
		var map = project_load_start(fn);
		if (map = null)
			return 0
		
		// Save current settings
		var hobj;
		
		// Combine with "Render settings" action?
		if (history[0] != null && history[0].script = action_project_render_settings)
			hobj = history[0]
		else
			hobj = history_set(action_project_render_import)
		
		hobj.save_obj_old = new_obj(obj_history_save)
		hobj.save_obj_new = new_obj(obj_history_save)
		hobj.fn = fn
		
		// Save old settings
		with (hobj.save_obj_old)
			history_copy_render_settings(app)
		
		project_load_render(map[?"render"])
		ds_map_destroy(map)
		
		// Save new settings
		with (hobj.save_obj_new)
			history_copy_render_settings(app)
		
		log("Loaded render settings", fn)
	}
}