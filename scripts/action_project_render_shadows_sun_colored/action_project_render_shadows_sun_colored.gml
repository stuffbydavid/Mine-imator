/// action_project_render_shadows_sun_colored(enable)
/// @arg value

function action_project_render_shadows_sun_colored(enable)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_sun_colored, project_render_shadows_sun_colored, enable, 1)
	
	project_render_shadows_sun_colored = enable
	render_samples = -1
}
