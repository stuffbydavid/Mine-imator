/// action_project_render_ssao_radius(value, add)
/// @arg value
/// @arg add

function action_project_render_ssao_radius(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_ssao_radius, project_render_ssao_radius, project_render_ssao_radius * add + val, 1)
	
	project_render_ssao_radius = project_render_ssao_radius * add + val
}
