/// action_project_render_glow_falloff_intensity(value, add)
/// @arg value
/// @arg add

function action_project_render_glow_falloff_intensity(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_glow_falloff_intensity, project_render_glow_falloff_intensity, project_render_aa_power * add + val / 100, 1)
	
	project_render_glow_falloff_intensity = project_render_glow_falloff_intensity * add + val / 100
}
