/// action_lib_pc_destroy_at_animation_finish(destroy)
/// @arg destroy

function action_lib_pc_destroy_at_animation_finish(destroy)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_animation_finish, temp_edit.pc_destroy_at_animation_finish, destroy, false)
	
	temp_edit.pc_destroy_at_animation_finish = destroy
}
