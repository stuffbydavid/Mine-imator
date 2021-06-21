/// action_project_render_reflections_fade_amount(value, add)
/// @arg value
/// @arg add

function action_project_render_reflections_fade_amount(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_reflections_fade_amount, project_render_reflections_fade_amount, project_render_reflections_fade_amount * add + val / 100, 1)
	else
		val *= 100
	
	project_render_reflections_fade_amount = project_render_reflections_fade_amount * add + val / 100
	render_samples = -1
}