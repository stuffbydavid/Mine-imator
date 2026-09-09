/// action_project_render_preset_edit_locked()
/// If the selected render preset is locked, copy all settings to "custom" and select it instead.

function action_project_render_preset_edit_locked()
{
	var custom = render_preset_map[?"custom"];
	
	if (history_undo && history_data.save_render_preset_locked)
	{
		// Restore old custom settings
		with (history_data)
			render_preset_copy(custom)
		action_project_render_preset(render_preset_edit.file)
		return 0
	}

	if (!render_preset_edit.locked && !(history_redo && history_data.save_render_preset_locked))
		return 0

	if (render_preset_edit = custom)
		return 0
	
	if (!history_redo)
	{
		var hobj = history_set(action_project_render_preset_edit_locked);
		hobj.save_render_preset_locked = true
		
		// Save previous custom values
		with (hobj)
			render_preset_clear()
		with (custom)
			render_preset_copy(hobj)
	}
	
	// Copy values
	with (render_preset_edit)
		render_preset_copy(custom)
	
	project_render_preset[renderer_edit] = "custom"
	render_preset_edit = custom
}
