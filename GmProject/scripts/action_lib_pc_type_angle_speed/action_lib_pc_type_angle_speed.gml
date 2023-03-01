/// action_lib_pc_type_angle_speed(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_angle_speed(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_angle_speed, ptype_edit.angle_speed, ptype_edit.angle_speed * add + val, true)
	
	ptype_edit.angle_speed = ptype_edit.angle_speed * add + val
}
