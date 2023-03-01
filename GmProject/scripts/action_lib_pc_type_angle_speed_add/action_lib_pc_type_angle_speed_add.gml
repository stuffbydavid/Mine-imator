/// action_lib_pc_type_angle_speed_add(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_angle_speed_add(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_angle_speed_add, ptype_edit.angle_speed_add, ptype_edit.angle_speed_add * add + val, true)
	
	ptype_edit.angle_speed_add = ptype_edit.angle_speed_add * add + val
}
