/// action_lib_pc_type_angle_speed_israndom(israndom)
/// @arg israndom

function action_lib_pc_type_angle_speed_israndom(israndom)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_angle_speed_israndom, ptype_edit.angle_speed_israndom, israndom, false)
	
	ptype_edit.angle_speed_israndom = israndom
}
