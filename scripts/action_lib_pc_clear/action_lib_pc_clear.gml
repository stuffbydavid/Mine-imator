/// action_lib_pc_clear()
/// @desc Clears all particles.

with (obj_timeline)
	if (particles)
		particle_spawner_clear()

with (obj_preview)
	particle_spawner_clear()
