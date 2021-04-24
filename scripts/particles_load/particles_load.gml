/// particles_load(filename, template)
/// @arg filename
/// @arg template
/// @desc Loads a particle spawner file into the given template.

function particles_load(fn, temp)
{
	var hobj;
	hobj = null
	
	if (history_undo)
	{
		temp = save_id_find(history_data.temp_save_id)
		with (temp)
			temp_particles_type_clear()
		
		with (history_data)
		{
			history_destroy_loaded()
			temp_particles_copy(temp)
		}
	
		with (temp)
		{
			for (var t = 0; t < history_data.pc_type_amount; t++)
				history_restore_ptype(history_data.pc_type_save_obj[t], id)
			temp_particles_restart()
		}
	
		tab_template_editor_update_ptype_list()
		return 0
	}
	else if (history_redo)
	{
		fn = history_data.filename
		temp = save_id_find(history_data.temp_save_id)
	}
	
	if (filename_ext(fn) = ".zip") // Unzip
	{
		var name = filename_new_ext(filename_name(fn), "");
		unzip(fn)
		
		fn = file_find_single(unzip_directory, ".miparticles;*.particles")
		if (!file_exists_lib(fn)) // Look in a subfolder with the same name as archive
			fn = file_find_single(unzip_directory + name + "\\", ".miparticles;*.particles")
		
		if (!file_exists_lib(fn))
		{
			error("erroropenparticleszip")
			return 0
		}
	}
	
	if (!file_exists_lib(fn))
		return 0
	
	if (!history_redo && temp != bench_settings)
	{
		hobj = history_set(particles_load)
		
		with (hobj)
		{
			filename = fn
			id.temp_save_id = save_id_get(temp)
		}
		
		with (temp)
		{
			temp_particles_copy(hobj)
			hobj.pc_type_amount = ds_list_size(pc_type_list)
			for (var t = 0; t < hobj.pc_type_amount; t++)
				hobj.pc_type_save_obj[t] = history_save_ptype(pc_type_list[|t])
		}
	}
	
	// Post 1.1.0 (JSON)
	var rootmap, legacy;
	if (string_contains(filename_ext(fn), ".miparticles"))
	{
		log("Opening particles", fn)
		rootmap = project_load_start(fn)
		if (rootmap = null)
			return 0
		
		legacy = false
	}
	
	// Pre 1.1.0 (buffer)
	else
	{
		log("Opening legacy particles", fn)
		if (!project_load_legacy_start(fn))
			return 0
		
		legacy = true
	}
	
	project_reset_loaded()
	
	save_folder = project_folder
	load_folder = filename_dir(fn)
	log("save_folder", save_folder)
	log("load_folder", load_folder)
	
	if (!legacy)
	{
		with (temp)
		{
			temp_particles_type_clear()
			project_load_particles(rootmap[?"particles"])
			temp_particles_restart()
		}
		project_load_objects(rootmap)
	}
	else
	{
		with (temp)
		{
			temp_particles_type_clear()
			project_load_legacy_particles()
			temp_particles_restart()
		}
		project_load_legacy_objects()
	}
	
	// Update program
	project_load_find_save_ids()
	project_load_update()
	
	// Mark for undo
	with (hobj)
		history_save_loaded()
	
	project_reset_loaded()
	
	tab_template_editor_update_ptype_list()
	
	log("Particles loaded")
}
