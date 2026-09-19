/// action_project_render_block_subsurface(value, add)
/// @arg value
/// @arg add

function action_project_render_block_subsurface(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_block_subsurface, project_render_block_subsurface, project_render_block_subsurface * add + val, 1)
	
	project_render_block_subsurface = project_render_block_subsurface * add + val
	render_samples = -1
}
