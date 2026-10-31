function action_project_render_water_reflections(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_water_reflections, project_render_water_reflections, enabled, true)
	
	project_render_water_reflections = enabled
}
