function action_project_render_texture_filtering_level(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_texture_filtering_level, project_render_texture_filtering_level, project_render_texture_filtering_level * add + value, true)
	
	project_render_texture_filtering_level = project_render_texture_filtering_level * add + value
	render_samples = -1

	texture_set_mipmap_level(project_render_texture_filtering_level)
}
