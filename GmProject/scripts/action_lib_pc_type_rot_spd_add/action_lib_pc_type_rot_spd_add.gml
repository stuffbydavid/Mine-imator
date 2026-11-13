function action_lib_pc_type_rot_spd_add(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_rot_spd_add, ptype_edit.rot_spd_add[axis_edit], ptype_edit.rot_spd_add[axis_edit] * add + value, true)
	
	ptype_edit.rot_spd_add[axis_edit] = ptype_edit.rot_spd_add[axis_edit] * add + value
}
