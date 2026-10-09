function action_lib_pc_bounding_box_relative(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_bounding_box_relative, obj_edit.pc_bounding_box_relative, enabled, false)
	
	obj_edit.pc_bounding_box_relative = enabled
}
