/// action_project_render_water_reflections(value)
/// @arg value

function action_project_render_water_reflections(value)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_water_reflections, project_render_water_reflections, value, 1)
	
	project_render_water_reflections = value
}
