/// action_lib_pc_destroy_at_time_seconds(value, add)
/// @arg value
/// @arg add

function action_lib_pc_destroy_at_time_seconds(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_time_seconds, temp_edit.pc_destroy_at_time_seconds, temp_edit.pc_destroy_at_time_seconds * add + val, true)
	
	temp_edit.pc_destroy_at_time_seconds = temp_edit.pc_destroy_at_time_seconds * add + val
}
