/// action_bench_particles_export()

function action_bench_particles_export()
{
	var preset = bench_settings.particle_preset
	if (preset = null)
		return 0
	
	if (!is_string(preset))
	{
		particles_save(preset)
		return 0
	}
	
	var source = file_exists_lib(preset) ? preset : particles_directory + bench_particle_preset_folder + "/" + preset + ".miparticles"
	if (!file_exists_lib(source))
		return 0
	
	var presetname = filename_new_ext(filename_name(source), "");
	if (filename_ext(source) != ".miparticles")
	{
		particles_save(bench_settings, presetname)
		return 0
	}
	
	var fn = file_dialog_save_particles(presetname)
	if (fn = "")
		return 0
	
	file_copy_lib(source, filename_new_ext(fn, ".miparticles"))
}
