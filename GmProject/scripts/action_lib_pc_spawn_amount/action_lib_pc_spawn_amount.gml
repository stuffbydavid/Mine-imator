function action_lib_pc_spawn_amount(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_spawn_amount, obj_edit.pc_spawn_amount, obj_edit.pc_spawn_amount * add + value, true)
	
	with (obj_edit)
	{
		pc_spawn_amount = pc_spawn_amount * add + value
		temp_particles_restart()
	}
}
