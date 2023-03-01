/// action_project_render_shadows_transparent(enable)
/// @arg enable

function action_project_render_shadows_transparent(enable)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_transparent, project_render_shadows_transparent, enable, 1)
	
	project_render_shadows_transparent = enable
	render_samples = -1
}
