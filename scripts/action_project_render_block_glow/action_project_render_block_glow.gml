/// action_project_render_block_glow(value)
/// @arg value

function action_project_render_block_glow(val)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_block_glow, project_render_block_glow, val, 1)
	
	project_render_block_glow = val
}
