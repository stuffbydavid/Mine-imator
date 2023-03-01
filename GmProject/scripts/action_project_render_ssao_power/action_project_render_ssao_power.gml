/// action_project_render_ssao_power(value, add)
/// @arg value
/// @arg add

function action_project_render_ssao_power(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_ssao_power, project_render_ssao_power, project_render_ssao_power * add + val / 100, 1)
	else
		val *= 100
	
	project_render_ssao_power = project_render_ssao_power * add + val / 100
}
