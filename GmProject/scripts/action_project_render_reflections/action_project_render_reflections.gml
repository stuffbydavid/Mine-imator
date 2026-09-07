/// action_project_render_reflections(enable)
/// @arg enable

function action_project_render_reflections(enable)
{
	action_project_render_preset_edit_locked()
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_reflections, render_preset_edit.realistic_reflections, enable, true)
	
	render_preset_edit.realistic_reflections = enable
	render_samples = -1
}
