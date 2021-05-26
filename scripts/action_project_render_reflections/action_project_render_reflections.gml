/// action_project_render_reflections(enable)
/// @arg enable

function action_project_render_reflections(enable)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_reflections, project_render_reflections, enable, 1)
	
	project_render_reflections = enable
	render_samples = -1
}
