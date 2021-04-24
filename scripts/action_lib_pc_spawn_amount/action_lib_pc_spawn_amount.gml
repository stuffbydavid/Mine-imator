/// action_lib_pc_spawn_amount(value, add)
/// @arg value
/// @arg add

function action_lib_pc_spawn_amount(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_spawn_amount, temp_edit.pc_spawn_amount, temp_edit.pc_spawn_amount * add + val, true)
	
	with (temp_edit)
	{
		pc_spawn_amount = pc_spawn_amount * add + val
		temp_particles_restart()
	}
}
