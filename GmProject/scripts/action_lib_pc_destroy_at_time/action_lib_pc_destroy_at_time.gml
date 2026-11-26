function action_lib_pc_destroy_at_time(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_time, obj_edit.pc_destroy_at_time, enabled, false)
	
	obj_edit.pc_destroy_at_time = enabled
}
