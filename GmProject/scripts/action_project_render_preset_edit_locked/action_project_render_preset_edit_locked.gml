/// action_project_render_preset_edit_locked()
/// If the selected render preset is locked, copy all settings to "custom" and select it instead.

function action_project_render_preset_edit_locked()
{
	var custom = render_preset_map[?"custom"];
	
	if (history_undo && history_data.save_render_preset_locked)
	{
		// Restore old custom settings
		with (custom)
		{
			render_preset_copy_settings(history_data, e_renderer.STANDARD)
			render_preset_copy_settings(history_data, e_renderer.REALISTIC)
			render_preset_copy_settings(history_data, e_renderer.COMMON)
		}
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
		with (hobj)
		{
			// Save previous custom values
			has_standard = false
			has_realistic = false
			has_fx = false
			has_graphics = false
			has_materials = false
			render_preset_copy_settings(custom, e_renderer.STANDARD)
			render_preset_copy_settings(custom, e_renderer.REALISTIC)
			render_preset_copy_settings(custom, e_renderer.COMMON)
		}
	}
	
	// Copy values
	with (custom)
	{
		render_preset_copy_settings(render_preset_edit, e_renderer.STANDARD)
		render_preset_copy_settings(render_preset_edit, e_renderer.REALISTIC)
		render_preset_copy_settings(render_preset_edit, e_renderer.COMMON)
	}
	
	project_render_preset[renderer_edit] = "custom"
	render_preset_edit = custom
}
