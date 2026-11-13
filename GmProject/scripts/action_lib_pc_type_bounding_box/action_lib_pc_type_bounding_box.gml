function action_lib_pc_type_bounding_box(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_bounding_box, ptype_edit.bounding_box, enabled, false)
	
	ptype_edit.bounding_box = enabled
}
