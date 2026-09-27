/// action_project_render_water_wave_detail(value, add)
/// @arg value
/// @arg add

function action_project_render_water_wave_detail(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_water_wave_detail, project_render_water_wave_detail, project_render_water_wave_detail * add + val, true)

	project_render_water_wave_detail = project_render_water_wave_detail * add + val
	render_samples = -1
}
