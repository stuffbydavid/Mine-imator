function action_project_render_ssao_power(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_ssao_power, project_render_ssao_power, project_render_ssao_power * add + value / 100, true)
	else
		value *= 100
	
	project_render_ssao_power = project_render_ssao_power * add + value / 100
}
