function action_lib_pc_destroy_at_bounding_box(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_destroy_at_bounding_box, obj_edit.pc_destroy_at_bounding_box, enabled, false)
	
	obj_edit.pc_destroy_at_bounding_box = enabled
}
