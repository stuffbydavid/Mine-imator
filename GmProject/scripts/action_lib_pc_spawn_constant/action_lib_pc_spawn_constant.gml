/// action_lib_pc_spawn_constant(constant)
/// @arg constant

function action_lib_pc_spawn_constant(constant)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_spawn_constant, obj_edit.pc_spawn_constant, constant, false)
	
	with (obj_edit)
	{
		pc_spawn_constant = constant
		temp_particles_restart()
	}
}
