/// action_project_render_subsurface_jitter(value, add)
/// @arg value
/// @arg add

function action_project_render_subsurface_jitter(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_subsurface_jitter, project_render_subsurface_jitter, project_render_subsurface_jitter * add + val / 100, 1)
	
	project_render_subsurface_jitter = project_render_subsurface_jitter * add + val / 100
	render_samples = -1
}
