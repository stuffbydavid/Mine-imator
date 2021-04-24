/// action_lib_pc_spawn_constant(constant)
/// @arg constant

function action_lib_pc_spawn_constant(constant)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_spawn_constant, temp_edit.pc_spawn_constant, constant, false)
	
	with (temp_edit)
	{
		pc_spawn_constant = constant
		temp_particles_restart()
	}
}
