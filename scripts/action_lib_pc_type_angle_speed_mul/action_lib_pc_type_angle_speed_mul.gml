/// action_lib_pc_type_angle_speed_mul(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_angle_speed_mul(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_angle_speed_mul, ptype_edit.angle_speed_mul, ptype_edit.angle_speed_mul * add + val, true)
	
	ptype_edit.angle_speed_mul = ptype_edit.angle_speed_mul * add + val
}
