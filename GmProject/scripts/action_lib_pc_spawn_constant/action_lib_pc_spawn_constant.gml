function action_lib_pc_spawn_constant(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_spawn_constant, obj_edit.pc_spawn_constant, enabled, false)
	
	with (obj_edit)
	{
		pc_spawn_constant = enabled
		temp_particles_restart()
	}
}
