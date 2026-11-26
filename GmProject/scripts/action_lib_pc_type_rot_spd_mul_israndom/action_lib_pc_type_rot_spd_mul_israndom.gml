function action_lib_pc_type_rot_spd_mul_israndom(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_rot_spd_mul_israndom, ptype_edit.rot_spd_mul_israndom[axis_edit], enabled, false)
	
	ptype_edit.rot_spd_mul_israndom[axis_edit] = enabled
}
