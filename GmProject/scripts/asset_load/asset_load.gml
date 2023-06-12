/// asset_load([filename])
/// @arg [filename]
/// @desc Adds a file to the project.
/// A file browser appears if no filename is given.

function asset_load()
{
	var fn;
	
	if (history_undo)
	{
		with (history_data)
			history_destroy_loaded()
		
		tl_update_length()
		tl_update_list()
		lib_preview.update = true
		res_preview.update = true
		
		return false
	}
	else if (history_redo)
		fn = history_data.filename
	else
	{
		if (argument_count > 0)
			fn = argument[0]
		else
			fn = file_dialog_open_asset()
	}
	
	if (fn = "" || !file_exists_lib(fn))
		return false
	
	var ext = string_lower(filename_ext(fn));
	if (ext = ".zip")
	{
		// Unzip and look for valid files
		var validfile = unzip_asset(fn);
		
		if (file_exists_lib(validfile))
		{
			fn = validfile
			ext = filename_ext(fn)
		} 
		else
		{
			// Look for pack
			if (directory_exists_lib(unzip_directory + "assets"))
				action_res_pack_load(fn)
			else
				error("erroropenassetzip")
			return false
		}
	}
	
	// Check formats
	var legacy = false;
	switch (ext)
	{
		case ".miobject":
		case ".miparticles":
		case ".miproject":
			legacy = false
			break
		
		case ".object":
		case ".particles":
		case ".mproj":
		case ".mani":
			legacy = true
			break
		
		case ".miframes":
		case ".keyframes":
			log("Opening keyframes", fn)
			action_tl_keyframes_load(fn)
			return true
		
		case ".schematic":
		case ".nbt":
		case ".blocks":
			log("Opening scenery", fn)
			action_lib_scenery_load(fn)
			return true
		
		case ".mimodel":
		case ".json":
			log("Opening model", fn)
			action_res_model_load(fn)
			return true
		
		case ".mp3":
		case ".wav":
		case ".ogg":
		case ".flac":
		case ".wma":
		case ".m4a":
			log("Opening audio", fn)
			action_res_sound_load(fn)
			return true
		
		case ".ttf":
			log("Adding font", fn)
			action_res_font_load(fn)
			return true
		
		case ".png":
		case ".jpg":
		case ".jpeg":
			log("Opening image", fn)
			popup_importimage.filename = fn
			popup_show(popup_importimage)
			return true
	}
	
	var hobj = null;
	if (!history_redo)
		hobj = history_set(asset_load)
	
	// Post 1.1.0 (JSON)
	var rootmap;
	if (!legacy)
	{
		log("Opening asset", fn)
		rootmap = project_load_start(fn)
		if (rootmap = null)
			return false
	}
	
	// Pre 1.1.0 (buffer)
	else
	{
		log("Opening legacy asset", fn)
		if (!project_load_legacy_start(fn))
			return false
	}
	
	project_reset_loaded()
	
	save_folder = project_folder
	load_folder = filename_dir(fn)
	log("save_folder", save_folder)
	log("load_folder", load_folder)
	
	switch (ext)
	{
		// Object
		case ".miproject":
		case ".miobject":
		{
			project_load_objects(rootmap)
			project_load_find_save_ids()
			project_load_update()
			break
		}
		case ".object":
		{
			project_load_legacy_objects()
			project_load_find_save_ids()
			project_load_update()
			buffer_delete(buffer_current)
			break
		}
		
		// Particle spawner
		case ".miparticles":
		{
			var temp = new_obj(obj_template);
			with (temp)
			{
				loaded = true
				load_id = save_id
				save_id_map[?load_id] = load_id
				type = e_temp_type.PARTICLE_SPAWNER
				project_load_particles(rootmap[?"particles"])
				sortlist_add(other.lib_list, id)
			}
			project_load_objects(rootmap)
			project_load_find_save_ids()
			
			with (temp)
				with (temp_animate())
					loaded = true
			
			project_load_update()
			break
		}
		case ".particles":
		{
			var temp = new_obj(obj_template);
			with (temp)
			{
				loaded = true
				load_id = save_id
				save_id_map[?load_id] = load_id
				type = e_temp_type.PARTICLE_SPAWNER
				project_load_legacy_particles()
				sortlist_add(other.lib_list, id)
			}
			project_load_legacy_objects()
			project_load_find_save_ids()
			
			with (temp)
				with (temp_animate())
					loaded = true
			
			project_load_update()
			buffer_delete(buffer_current)
			break
		}
		
		// Legacy project
		case ".mproj":
		{
			with (new_obj(obj_data))
			{
				project_load_legacy_project()
				instance_destroy()
			}
			project_load_legacy_objects()
			project_load_find_save_ids()
			project_load_update()
			buffer_delete(buffer_current)
			break
		}
		
		case ".mani":
		{
			project_load_legacy_beta(false)
			project_load_find_save_ids()
			project_load_update()
			buffer_delete(buffer_current)
			break
		}
	}
	
	// Mark for undo
	with (hobj)
	{
		filename = fn
		history_save_loaded()
	}
	
	project_reset_loaded()
	
	log("Asset loaded")
	
	return true
}
