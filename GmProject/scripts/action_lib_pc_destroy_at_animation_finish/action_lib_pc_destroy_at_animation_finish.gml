function action_lib_pc_destroy_at_animation_finish(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_animation_finish, obj_edit.pc_destroy_at_animation_finish, enabled, false)
	
	obj_edit.pc_destroy_at_animation_finish = enabled
}
