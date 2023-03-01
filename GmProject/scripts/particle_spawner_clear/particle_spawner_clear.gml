/// particle_spawner_clear()

function particle_spawner_clear()
{
	with (obj_particle)
		if (creator = other.id)
			instance_destroy()
	
	spawn_queue_start = null
}
