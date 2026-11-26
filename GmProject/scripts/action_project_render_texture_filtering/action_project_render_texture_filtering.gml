function action_project_render_texture_filtering(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_texture_filtering, project_render_texture_filtering, enabled, true)
	
	project_render_texture_filtering = enabled
	render_samples = -1
}
