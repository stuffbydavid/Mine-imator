/// action_lib_pc_destroy_at_time_random_max(value, add)
/// @arg value
/// @arg add

function action_lib_pc_destroy_at_time_random_max(argument0, argument1)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_time_random_max, temp_edit.pc_destroy_at_time_random_max, temp_edit.pc_destroy_at_time_random_max * add + val, true)
	
	temp_edit.pc_destroy_at_time_random_max = temp_edit.pc_destroy_at_time_random_max * add + val
}
