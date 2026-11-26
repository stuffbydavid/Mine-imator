function action_lib_pc_type_angle_random_min(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_angle_random_min, ptype_edit.angle_random_min[axis_edit], ptype_edit.angle_random_min[axis_edit] * add + value, true)
	
	ptype_edit.angle_random_min[axis_edit] = ptype_edit.angle_random_min[axis_edit] * add + value
}
