/// action_project_render_shadows_blur_size(value, add)
/// @arg value
/// @arg add

function action_project_render_shadows_blur_size(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_blur_size, project_render_shadows_blur_size, project_render_shadows_blur_size * add + val / 100, true)
	
	project_render_shadows_blur_size = project_render_shadows_blur_size * add + val / 100
}
