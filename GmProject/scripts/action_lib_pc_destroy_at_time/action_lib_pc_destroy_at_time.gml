/// action_lib_pc_destroy_at_time(destroy)
/// @arg destroy

function action_lib_pc_destroy_at_time(destroy)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_time, obj_edit.pc_destroy_at_time, destroy, false)
	
	obj_edit.pc_destroy_at_time = destroy
}
