/// action_project_render_opaque_leaves(value)
/// @arg value

function action_project_render_opaque_leaves(value)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_opaque_leaves, project_render_opaque_leaves, value, true)
	
	project_render_opaque_leaves = value
	toast_new(e_toast.WARNING, text_get("alertreloadobjects"))
}
