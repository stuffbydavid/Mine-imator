function action_lib_pc_destroy_at_time_random_max(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_time_random_max, obj_edit.pc_destroy_at_time_random_max, obj_edit.pc_destroy_at_time_random_max * add + value, true)
	
	obj_edit.pc_destroy_at_time_random_max = obj_edit.pc_destroy_at_time_random_max * add + value
}
