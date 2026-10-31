function action_lib_pc_type_angle(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_angle, ptype_edit.angle[axis_edit], ptype_edit.angle[axis_edit] * add + value, true)
	
	ptype_edit.angle[axis_edit] = ptype_edit.angle[axis_edit] * add + value
}
