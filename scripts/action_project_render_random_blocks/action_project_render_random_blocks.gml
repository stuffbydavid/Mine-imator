/// action_project_render_random_blocks(value)
/// @arg value

function action_project_render_random_blocks(value)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_random_blocks, project_render_random_blocks, value, 1)
	
	project_render_random_blocks = value
	toast_new(e_toast.WARNING, text_get("alertreloadobjects"))
}
