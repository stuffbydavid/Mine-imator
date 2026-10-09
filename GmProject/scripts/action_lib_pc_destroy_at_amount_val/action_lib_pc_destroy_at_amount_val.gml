function action_lib_pc_destroy_at_amount_val(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_amount_val, obj_edit.pc_destroy_at_amount_val, obj_edit.pc_destroy_at_amount_val * add + value, true)
	
	obj_edit.pc_destroy_at_amount_val = obj_edit.pc_destroy_at_amount_val * add + value
}
