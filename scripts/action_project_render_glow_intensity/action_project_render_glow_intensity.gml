/// action_project_render_glow_intensity(value, add)
/// @arg value
/// @arg add

function action_project_render_glow_intensity(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_glow_intensity, project_render_glow_intensity, project_render_glow_intensity * add + val / 100, 1)
	else
		val *= 100
	
	project_render_glow_intensity = project_render_glow_intensity * add + val / 100
}
