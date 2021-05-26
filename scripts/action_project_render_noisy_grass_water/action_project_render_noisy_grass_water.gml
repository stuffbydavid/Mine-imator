/// action_project_render_noisy_grass_water(value)
/// @arg value

function action_project_render_noisy_grass_water(value)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_noisy_grass_water, project_render_noisy_grass_water, value, 1)
	
	project_render_noisy_grass_water = value
	toast_new(e_toast.WARNING, text_get("alertreloadobjects"))
}
