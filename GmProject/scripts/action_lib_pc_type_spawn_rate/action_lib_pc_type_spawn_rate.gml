function action_lib_pc_type_spawn_rate(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_spawn_rate, ptype_edit.spawn_rate * 100, ptype_edit.spawn_rate * add * 100 + value, true)
	
	var addval;
	if (add)
		addval = value / 100
	else
		addval = value / 100 - ptype_edit.spawn_rate
	
	ptype_edit.spawn_rate += addval
	
	with (obj_edit)
	{
		temp_particles_update_spawn_rate(ptype_edit, addval)
		temp_particles_restart()
	}
}
