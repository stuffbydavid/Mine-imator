function action_project_render_glow_intensity(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_glow_intensity, project_render_glow_intensity, project_render_glow_intensity * add + value / 100, true)
	else
		value *= 100
	
	project_render_glow_intensity = project_render_glow_intensity * add + value / 100
}
