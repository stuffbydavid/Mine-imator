/// action_project_render_block_glow_threshold(value, add)
/// @arg value
/// @arg add

function action_project_render_block_glow_threshold(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_block_glow_threshold, project_render_block_glow_threshold, project_render_block_glow_threshold * add + val / 100, 1)
	else
		val *= 100
	
	project_render_block_glow_threshold = project_render_block_glow_threshold * add + val / 100
}
