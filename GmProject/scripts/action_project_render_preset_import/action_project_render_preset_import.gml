/// @arg [filename]

function action_project_render_preset_import(fn = "")
{
	if (history_undo)
	{
		// Restore old settings of project
		history_copy_render_settings(history_data)
		
		// Restore old settings of preset
		with (history_data)
			render_preset_copy(render_preset_edit, true)

		render_apply_settings(render_preset_edit, e_renderer.COMMON)
		render_samples = -1
		
		return 0
	}
	else if (history_redo)
		fn = history_data.filename

	if (fn != null)
	{
		if (fn = "")
			fn = file_dialog_open_render()
		
		if (!file_exists_lib(fn) || fn = "")
			return false
	}
		
	if (!history_redo)
	{
		var hobj = history_set(action_project_render_preset_import);
		hobj.filename = fn

		// Save both project and preset settings
		with (hobj)
		{
			render_preset_event_create()
			history_copy_render_settings(app)
		}
		with (render_preset_edit)
			render_preset_copy(hobj, true)
	}

	if (fn = null)
	{
		// Reset both renderers from the loaded default preset
		with (render_preset_map[?render_preset_default])
			render_preset_copy(render_preset_edit, true)
		
		// Common settings belong to the project, not a Custom snapshot
		with (render_preset_edit)
		{
			has_standard = true
			has_realistic = true
			has_fx = false
			has_graphics = false
			has_materials = false
		}
		
		render_apply_settings(render_default_settings, e_renderer.COMMON)
	}
	else
	{
		with (render_preset_edit)
			render_preset_load(fn, false)
		
		// Apply common settings in preset
		render_apply_settings(render_preset_edit, e_renderer.COMMON)
		
		log("Imported render settings", fn)
	}
	
	render_samples = -1
	
	return true
}
