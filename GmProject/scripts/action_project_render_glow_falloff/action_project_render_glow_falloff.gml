/// action_project_render_glow_falloff(enable)
/// @arg enable

function action_project_render_glow_falloff(enable)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_glow_falloff, project_render_glow_falloff, enable, true)
	
	project_render_glow_falloff = enable
}
