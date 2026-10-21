function action_lib_pc_type_rot_spawner_angle(value)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_rot_spawner_angle, ptype_edit.rot_spawner_angle, value, false)
	
	ptype_edit.rot_spawner_angle = value
}
