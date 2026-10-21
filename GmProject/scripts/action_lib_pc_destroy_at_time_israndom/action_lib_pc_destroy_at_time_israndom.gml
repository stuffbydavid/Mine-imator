function action_lib_pc_destroy_at_time_israndom(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_time_israndom, obj_edit.pc_destroy_at_time_israndom, enabled, false)
	
	obj_edit.pc_destroy_at_time_israndom = enabled
}
