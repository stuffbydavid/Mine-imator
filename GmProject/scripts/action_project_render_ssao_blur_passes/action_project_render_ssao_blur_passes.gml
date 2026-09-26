/// action_project_render_ssao_blur_passes(value, add)
/// @arg value
/// @arg add

function action_project_render_ssao_blur_passes(val, add)
{
	var passes = clamp(round(project_render_ssao_blur_passes * add + val), 0, 8)
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_ssao_blur_passes, project_render_ssao_blur_passes, passes, true)
	
	project_render_ssao_blur_passes = passes
}
