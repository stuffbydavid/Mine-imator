/// action_bench_particles_folder(folder, [update])
/// @arg folder
/// @arg [update]

function action_bench_particles_folder(folder, update = true)
{
	bench_particle_preset_folder = folder
	temp_creator = bench_settings
	bench_clear()
	
	with (bench_settings)
		temp_particles_type_clear()
		
	temp_creator = app
	with (bench_settings.preview)
	{
		particle_spawner_clear()
		self.update = true
	}
	
	var list, selected;
	list = bench_settings.particle_preset_list
	selected = bench_settings.particle_preset
	list.search = false
	list.search_tbx.text = ""
	list.scroll.value = 0
	list.scroll.value_goal = 0
	ds_list_clear(list.list)
	
	bench_settings.particle_preset = null
	bench_settings.particle_preset_temp = null
	
	if (folder = "project")
	{
		// List templates
		for (var i = 0; i < ds_list_size(lib_list.list); i++)
		{
			var temp = lib_list.list[|i]
			if (temp.type = e_temp_type.PARTICLE_SPAWNER)
				sortlist_add(list, temp)
		}
	}
	else
	{
		// List files
		var dir = particles_directory + folder + "/"
		if (directory_exists_lib(dir))
		{
			var files = file_find(dir, ".miparticles")
			for (var i = 0; i < array_length(files); i++)
			{
				var name = filename_new_ext(filename_name(files[i]), "");
				sortlist_add(list, name)
			}
		}
	}
	
	if (update)
		sortlist_update(list)
	
	if (folder = "project")
	{
		if (selected != null && ds_list_find_index(list.display_list, selected) >= 0)
		{
			sortlist_view(list, selected)
			action_bench_particles_select(selected)
			return 0
		}
		
		if (ds_list_size(list.display_list) > 0)
			action_bench_particles_select(list.display_list[|0])
		
		return 0
	}
	
	// Select default particle for folder
	for (var i = 0; i < array_length(particle_folders); i++)
	{
		if (particle_folders[i] != folder)
			continue
		
		var particle = particle_default[i]
		if (ds_list_find_index(list.display_list, particle) >= 0)
		{
			sortlist_view(list, particle)
			action_bench_particles_select(particle)
		}
		break
	}
}
