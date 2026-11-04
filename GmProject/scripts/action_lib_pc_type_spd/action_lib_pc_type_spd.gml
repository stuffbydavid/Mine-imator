function action_lib_pc_type_spd(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_spd, ptype_edit.spd[axis_edit], ptype_edit.spd[axis_edit] * add + value, true)
	
	ptype_edit.spd[axis_edit] = ptype_edit.spd[axis_edit] * add + value
}
