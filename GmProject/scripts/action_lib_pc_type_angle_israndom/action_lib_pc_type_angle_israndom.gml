function action_lib_pc_type_angle_israndom(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_angle_israndom, ptype_edit.angle_israndom[axis_edit], enabled, false)
	
	ptype_edit.angle_israndom[axis_edit] = enabled
}
