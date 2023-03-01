/// action_lib_pc_destroy_at_time(destroy)
/// @arg destroy

function action_lib_pc_destroy_at_time(destroy)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_time, temp_edit.pc_destroy_at_time, destroy, false)
	
	temp_edit.pc_destroy_at_time = destroy
}
