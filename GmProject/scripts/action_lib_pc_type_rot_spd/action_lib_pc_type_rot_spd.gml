function action_lib_pc_type_rot_spd(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_rot_spd, ptype_edit.rot_spd[axis_edit], ptype_edit.rot_spd[axis_edit] * add + value, true)
	
	ptype_edit.rot_spd[axis_edit] = ptype_edit.rot_spd[axis_edit] * add + value
}
