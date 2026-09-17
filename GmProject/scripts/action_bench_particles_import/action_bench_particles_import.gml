/// action_bench_particles_import()

function action_bench_particles_import()
{
	var fn, temp, presetname;
	fn = file_dialog_open_particles()
	if (!file_exists_lib(fn))
		return 0

	presetname = filename_new_ext(filename_name(fn), "")
	
	temp = new_obj(obj_template)
	with (temp)
	{
		type = e_temp_type.PARTICLE_SPAWNER
		temp_particles_init()
		
		if (text_exists("benchparticles" + presetname))
			name = text_get("benchparticles" + presetname)
		else
			name = presetname
		
		temp_update_display_name()
	}
	
	particles_load(fn, temp, true)

	with (temp)
		temp_add_lists()
	bench_settings.particle_preset = temp
	action_bench_particles_folder("project")
}
