function action_lib_pc_type_spd_mul(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_spd_mul, ptype_edit.spd_mul[axis_edit], ptype_edit.spd_mul[axis_edit] * add + value, true)
	
	ptype_edit.spd_mul[axis_edit] = ptype_edit.spd_mul[axis_edit] * add + value
}
