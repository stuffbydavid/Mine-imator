/// action_project_render_glow_falloff_radius(value, add)
/// @arg value
/// @arg add

function action_project_render_glow_falloff_radius(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_glow_falloff_radius, project_render_glow_falloff_radius, project_render_glow_falloff_radius * add + val / 100, 1)
	
	project_render_glow_falloff_radius = project_render_glow_falloff_radius * add + val / 100
}
