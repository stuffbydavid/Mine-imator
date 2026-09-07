/// action_project_render_shadows_sun_buffer_size(size)
/// @arg size

function action_project_render_shadows_sun_buffer_size(size)
{
	if (size >= 8192)
		if (!question(text_get("questionbuffersizewarning")))
			return 0
	
	action_project_render_preset_edit_locked()
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_sun_buffer_size, renderer_edit_standard ? render_preset_edit.standard_shadows_sun_buffer_size : render_preset_edit.realistic_shadows_sun_buffer_size, size, true)
	
	if (renderer_edit_standard)
		render_preset_edit.standard_shadows_sun_buffer_size = size
	else
		render_preset_edit.realistic_shadows_sun_buffer_size = size
		
	render_samples = -1
}
