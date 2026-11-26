function action_project_render_glint_strength(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_glint_strength, project_render_glint_strength, project_render_glint_strength * add + value / 100, true)
	else
		value *= 100
	
	project_render_glint_strength = project_render_glint_strength * add + value / 100
	render_samples = -1
}
