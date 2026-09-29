function action_project_render_ssao_always_visible(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_ssao_always_visible, project_render_ssao_always_visible, enabled, true)

	project_render_ssao_always_visible = enabled
}
