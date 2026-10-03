function action_project_render_block_subsurface(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_block_subsurface, project_render_block_subsurface, project_render_block_subsurface * add + value, true)
	
	project_render_block_subsurface = project_render_block_subsurface * add + value
	render_samples = -1
}
