function action_lib_pc_type_angle_speed_mul(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_angle_speed_mul, ptype_edit.angle_speed_mul, ptype_edit.angle_speed_mul * add + value, true)
	
	ptype_edit.angle_speed_mul = ptype_edit.angle_speed_mul * add + value
}
