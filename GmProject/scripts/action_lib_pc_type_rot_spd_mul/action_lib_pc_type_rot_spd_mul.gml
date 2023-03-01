/// action_lib_pc_type_rot_spd_mul(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_rot_spd_mul(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_rot_spd_mul, ptype_edit.rot_spd_mul[axis_edit], ptype_edit.rot_spd_mul[axis_edit] * add + val, true)
	
	ptype_edit.rot_spd_mul[axis_edit] = ptype_edit.rot_spd_mul[axis_edit] * add + val
}
