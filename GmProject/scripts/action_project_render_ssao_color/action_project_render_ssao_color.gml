/// action_project_render_ssao_color(color)
/// @arg color

function action_project_render_ssao_color(color)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_ssao_color, project_render_ssao_color, color, true)
	
	project_render_ssao_color = color
}
