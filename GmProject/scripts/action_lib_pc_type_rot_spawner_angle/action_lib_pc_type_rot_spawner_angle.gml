/// action_lib_pc_type_rot_spawner_angle(value)
/// @arg value

function action_lib_pc_type_rot_spawner_angle(val)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_rot_spawner_angle, ptype_edit.rot_spawner_angle, val, false)
	
	ptype_edit.rot_spawner_angle = val
}
