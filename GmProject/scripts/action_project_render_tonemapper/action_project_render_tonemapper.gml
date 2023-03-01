/// action_project_render_tonemapper(tonemapper)
/// @arg tonemapper

function action_project_render_tonemapper(tonemapper)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_tonemapper, project_render_tonemapper, tonemapper, 1)
	
	project_render_tonemapper = tonemapper
	render_samples = -1
}
