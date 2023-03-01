/// action_project_render_texture_filtering(filtering)
/// @arg filtering

function action_project_render_texture_filtering(filtering)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_texture_filtering, project_render_texture_filtering, filtering, 1)
	
	project_render_texture_filtering = filtering
	render_samples = -1
}
