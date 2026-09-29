function action_project_render_water_wave_detail(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_water_wave_detail, project_render_water_wave_detail, project_render_water_wave_detail * add + value, true)

	project_render_water_wave_detail = project_render_water_wave_detail * add + value
	render_samples = -1
}
