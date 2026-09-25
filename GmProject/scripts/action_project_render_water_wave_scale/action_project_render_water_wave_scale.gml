/// action_project_render_water_wave_scale(value, add)
/// @arg value
/// @arg add

function action_project_render_water_wave_scale(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_water_wave_scale, project_render_water_wave_scale, project_render_water_wave_scale * add + val / 100, true)
	else
		val *= 100

	project_render_water_wave_scale = project_render_water_wave_scale * add + val / 100
	render_samples = -1
}
