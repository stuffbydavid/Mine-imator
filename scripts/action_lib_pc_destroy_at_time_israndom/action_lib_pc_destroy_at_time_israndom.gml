/// action_lib_pc_destroy_at_time_israndom(israndom)
/// @arg israndom

function action_lib_pc_destroy_at_time_israndom(israndom)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_time_israndom, temp_edit.pc_destroy_at_time_israndom, israndom, false)
	
	temp_edit.pc_destroy_at_time_israndom = israndom
}
