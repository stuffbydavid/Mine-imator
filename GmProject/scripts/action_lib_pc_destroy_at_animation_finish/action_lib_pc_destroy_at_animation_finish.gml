/// action_lib_pc_destroy_at_animation_finish(destroy)
/// @arg destroy

function action_lib_pc_destroy_at_animation_finish(destroy)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_animation_finish, obj_edit.pc_destroy_at_animation_finish, destroy, false)
	
	obj_edit.pc_destroy_at_animation_finish = destroy
}
