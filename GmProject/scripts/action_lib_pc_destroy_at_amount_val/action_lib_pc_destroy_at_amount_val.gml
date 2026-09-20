/// action_lib_pc_destroy_at_amount_val(value, add)
/// @arg value
/// @arg add

function action_lib_pc_destroy_at_amount_val(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_amount_val, obj_edit.pc_destroy_at_amount_val, obj_edit.pc_destroy_at_amount_val * add + val, true)
	
	obj_edit.pc_destroy_at_amount_val = obj_edit.pc_destroy_at_amount_val * add + val
}
