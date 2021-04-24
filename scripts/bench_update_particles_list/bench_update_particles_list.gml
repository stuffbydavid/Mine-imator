/// bench_update_particles_list()

function bench_update_particles_list()
{
	var files = file_find(particles_directory, ".miparticles");
	
	sortlist_clear(bench_settings.particles_list)
	if (array_length(files) > 0)
	{
		for (var f = 0; f < array_length(files); f++)
			sortlist_add(bench_settings.particles_list, files[f])
		
		action_bench_particles(files[0])
	}
	else
		action_bench_particles("")
}
