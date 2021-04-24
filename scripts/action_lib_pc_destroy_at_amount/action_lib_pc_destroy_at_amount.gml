/// action_lib_pc_destroy_at_amount(destroy)
/// @arg destroy

function action_lib_pc_destroy_at_amount(destroy)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_amount, temp_edit.pc_destroy_at_amount, destroy, false)
	
	temp_edit.pc_destroy_at_amount = destroy
}
