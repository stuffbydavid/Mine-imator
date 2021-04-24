/// action_background_opaque_leaves(opaque)
/// @arg opaque

function action_background_opaque_leaves(opaque)
{
	if (!history_undo && !history_redo)
		history_set_var(action_background_opaque_leaves, background_opaque_leaves, opaque, false)
	
	background_opaque_leaves = opaque
	toast_new(e_toast.WARNING, text_get("alertreloadobjects"))
}
