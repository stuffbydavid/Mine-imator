/// action_bench_particles_select(preset)
/// @arg preset

function action_bench_particles_select(preset)
{
	with (bench_settings.preview)
		particle_spawner_clear()
	
	bench_settings.particle_preset = preset
	bench_settings.particle_preset_temp = null
	
	if (is_string(preset))
		action_bench_particles(particles_directory + bench_particle_preset_folder + "/" + preset + ".miparticles")
	else
	{
		temp_creator = bench_settings
		
		bench_clear()
		with (bench_settings)
			temp_particles_type_clear()
			
		temp_creator = app
		bench_settings.particle_preset_temp = preset
		bench_settings.preview.fire = true
	}
	
	bench_settings.preview.update = true
}
