/// action_project_render_subsurface_bright_backlight(value)
/// @arg value

function action_project_render_subsurface_bright_backlight(value)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_subsurface_bright_backlight, project_render_subsurface_bright_backlight, value, true)

	project_render_subsurface_bright_backlight = value
	render_samples = -1
}
