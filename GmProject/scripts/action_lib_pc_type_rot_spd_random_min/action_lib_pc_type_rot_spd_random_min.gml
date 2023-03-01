/// action_lib_pc_type_rot_spd_random_min(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_rot_spd_random_min(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_rot_spd_random_min, ptype_edit.rot_spd_random_min[axis_edit], ptype_edit.rot_spd_random_min[axis_edit] * add + val, true)
	
	ptype_edit.rot_spd_random_min[axis_edit] = ptype_edit.rot_spd_random_min[axis_edit] * add + val
}
