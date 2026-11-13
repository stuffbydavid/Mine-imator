function action_lib_pc_destroy_at_time_random_min(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_time_random_min, obj_edit.pc_destroy_at_time_random_min, obj_edit.pc_destroy_at_time_random_min * add + value, true)
	
	obj_edit.pc_destroy_at_time_random_min = obj_edit.pc_destroy_at_time_random_min * add + value
}
