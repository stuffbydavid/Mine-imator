/// action_project_render_reflections_halfres(enable)
/// @arg enable

function action_project_render_reflections_halfres(enable)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_reflections_halfres, project_render_reflections_halfres, enable, 1)
	
	project_render_reflections_halfres = enable
	render_samples = -1
}
