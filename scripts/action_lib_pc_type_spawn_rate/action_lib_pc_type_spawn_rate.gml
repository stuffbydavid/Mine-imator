/// action_lib_pc_type_spawn_rate(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_spawn_rate(val, add)
{
	var addval;
	
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_spawn_rate, ptype_edit.spawn_rate * 100, ptype_edit.spawn_rate * add * 100 + val, true)
	
	if (add)
		addval = val / 100
	else
		addval = val / 100 - ptype_edit.spawn_rate
	
	ptype_edit.spawn_rate += addval
	with (temp_edit)
	{
		temp_particles_update_spawn_rate(ptype_edit, addval)
		temp_particles_restart()
	}
}
