/// action_lib_pc_type_rot_spd(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_rot_spd(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_rot_spd, ptype_edit.rot_spd[axis_edit], ptype_edit.rot_spd[axis_edit] * add + val, true)
	
	ptype_edit.rot_spd[axis_edit] = ptype_edit.rot_spd[axis_edit] * add + val
}
