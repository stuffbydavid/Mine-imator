/// action_project_render_ssao_blur_passes(value, add)
/// @arg value
/// @arg add

function action_project_render_ssao_blur_passes(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_ssao_blur_passes, project_render_ssao_blur_passes, project_render_ssao_blur_passes * add + val, 1)
	
	project_render_ssao_blur_passes = project_render_ssao_blur_passes * add + val
}
