function action_project_render_reflections_thickness(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_reflections_thickness, project_render_reflections_thickness, project_render_reflections_thickness * add + value, true)
	
	project_render_reflections_thickness = project_render_reflections_thickness * add + value
	render_samples = -1
}
