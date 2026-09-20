/// action_lib_pc_destroy_at_amount(destroy)
/// @arg destroy

function action_lib_pc_destroy_at_amount(destroy)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_amount, obj_edit.pc_destroy_at_amount, destroy, false)
	
	obj_edit.pc_destroy_at_amount = destroy
}
