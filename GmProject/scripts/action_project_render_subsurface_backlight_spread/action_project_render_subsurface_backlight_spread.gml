function action_project_render_subsurface_backlight_spread(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_subsurface_backlight_spread, project_render_subsurface_backlight_spread, project_render_subsurface_backlight_spread * add + value / 100, true)
	else
		value *= 100
	
	project_render_subsurface_backlight_spread = project_render_subsurface_backlight_spread * add + value / 100
	render_samples = -1
}
