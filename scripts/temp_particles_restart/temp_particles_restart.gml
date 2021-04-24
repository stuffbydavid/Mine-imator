/// temp_particles_restart()
/// @desc Restarts all spawners associated with the template.

function temp_particles_restart()
{
	with (obj_timeline)
		if (temp = other.id)
			particle_spawner_clear()
	
	with (obj_preview)
		if (select = other.id)
			particle_spawner_clear()
}
