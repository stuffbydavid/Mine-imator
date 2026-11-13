function action_lib_pc_type_angle_speed_mul_random_min(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_angle_speed_mul_random_min, ptype_edit.angle_speed_mul_random_min, ptype_edit.angle_speed_mul_random_min * add + value, true)
	
	ptype_edit.angle_speed_mul_random_min = ptype_edit.angle_speed_mul_random_min * add + value
}
