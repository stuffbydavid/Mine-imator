/// action_project_render_preset_import([fn])
/// @arg [fn]

function action_project_render_preset_import(fn = "")
{
	if (history_undo)
	{
		// Restore old settings of project
		history_copy_render_settings(history_data)
		
		// Restore old settings of preset
		with (render_preset_edit)
			render_preset_copy_settings(history_data, true)

		render_apply_settings(render_preset_edit, e_renderer.COMMON)
		render_samples = -1
		return 0
	}
	else if (history_redo)
		fn = history_data.filename

	if (fn = "")
		fn = file_dialog_open_render()

	if (!file_exists_lib(fn) || fn = "")
		return false
		
	if (!history_redo)
	{
		var hobj = history_set(action_project_render_preset_import);
		hobj.filename = fn
		
		// Save both project and preset settings
		with (hobj)
		{
			history_copy_render_settings(app)
			
			render_preset_clear()
			render_preset_copy_settings(render_preset_edit, true)
		}
	}

	with (render_preset_edit)
		render_preset_load(fn, false)

	// Apply common settings in preset
	render_apply_settings(render_preset_edit, e_renderer.COMMON)
	render_samples = -1
	
	log("Imported render settings", fn)
	return true
}
