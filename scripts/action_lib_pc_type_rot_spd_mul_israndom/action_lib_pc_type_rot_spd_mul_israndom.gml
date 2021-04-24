/// action_lib_pc_type_rot_spd_mul_israndom(israndom)
/// @arg israndom

function action_lib_pc_type_rot_spd_mul_israndom(israndom)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_rot_spd_mul_israndom, ptype_edit.rot_spd_mul_israndom[axis_edit], israndom, false)
	
	ptype_edit.rot_spd_mul_israndom[axis_edit] = israndom
}
