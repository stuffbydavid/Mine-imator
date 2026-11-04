function action_lib_pc_type_angle_extend(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_angle_extend, ptype_edit.angle_extend, enabled, false)
	
	ptype_edit.angle_extend = enabled
}
