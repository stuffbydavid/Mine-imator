/// action_lib_pc_destroy_at_time_random_min(value, add)
/// @arg value
/// @arg add

function action_lib_pc_destroy_at_time_random_min(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_time_random_min, temp_edit.pc_destroy_at_time_random_min, temp_edit.pc_destroy_at_time_random_min * add + val, true)
	
	temp_edit.pc_destroy_at_time_random_min = temp_edit.pc_destroy_at_time_random_min * add + val
}
