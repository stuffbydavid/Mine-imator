/// action_lib_pc_destroy_at_amount_val(value, add)
/// @arg value
/// @arg add

function action_lib_pc_destroy_at_amount_val(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_amount_val, temp_edit.pc_destroy_at_amount_val, temp_edit.pc_destroy_at_amount_val * add + val, true)
	
	temp_edit.pc_destroy_at_amount_val = temp_edit.pc_destroy_at_amount_val * add + val
}
