/// action_project_render_ssao_always_visible(enable)
/// @arg enable

function action_project_render_ssao_always_visible(enable)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_ssao_always_visible, project_render_ssao_always_visible, enable, 1)

	project_render_ssao_always_visible = enable
}
