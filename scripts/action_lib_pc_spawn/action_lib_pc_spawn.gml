/// action_lib_pc_spawn()
/// @desc Triggers spawning for all selected particle creators.

with (obj_timeline)
{
	if (type != e_temp_type.PARTICLE_SPAWNER)
		continue
	
	if (temp = temp_edit || selected)
	{
		if (temp.pc_spawn_constant)
			spawn_active = true
		else
			fire = true
	}
}
