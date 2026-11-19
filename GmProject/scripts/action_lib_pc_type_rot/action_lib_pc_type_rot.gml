function action_lib_pc_type_rot(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_rot, ptype_edit.rot[axis_edit], ptype_edit.rot[axis_edit] * add + value, true)
	
	ptype_edit.rot[axis_edit] = ptype_edit.rot[axis_edit] * add + value
}
