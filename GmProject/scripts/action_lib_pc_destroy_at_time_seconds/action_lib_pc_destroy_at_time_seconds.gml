function action_lib_pc_destroy_at_time_seconds(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_time_seconds, obj_edit.pc_destroy_at_time_seconds, obj_edit.pc_destroy_at_time_seconds * add + value, true)
	
	obj_edit.pc_destroy_at_time_seconds = obj_edit.pc_destroy_at_time_seconds * add + value
}
