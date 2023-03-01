/// action_lib_pc_clear()
/// @desc Clears all particles.

function action_lib_pc_clear()
{
	with (obj_timeline)
		if (particle_list != null)
			particle_spawner_clear()
	
	with (obj_preview)
		particle_spawner_clear()
}
