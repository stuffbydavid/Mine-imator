/// action_project_render_preset(file)
/// @arg preset

function action_project_render_preset(file)
{
	// Restore project settings
	if (history_undo && history_data.script = action_project_render_preset)
		history_copy_render_settings(history_data)
	
	if (!history_undo && !history_redo)
	{
		var hobj = history_set_var(action_project_render_preset, project_render_preset[renderer_edit], file, true)
		
		// Save project settings
		with (hobj)
			history_copy_render_settings(app)
	}
		
	project_render_preset[renderer_edit] = file
	
	// Apply common settings in preset
	render_apply_settings(render_preset_map[?file], e_renderer.COMMON)
	render_samples = -1
}
