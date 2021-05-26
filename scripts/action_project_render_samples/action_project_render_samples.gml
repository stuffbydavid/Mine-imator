/// action_project_render_samples(value, add)
/// @arg value
/// @arg add

function action_project_render_samples(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_samples, project_render_samples, project_render_samples * add + val, 1)
	
	var valold = project_render_samples;
	project_render_samples = project_render_samples * add + val
	
	if (project_render_samples < valold)
		render_samples = -1
}
