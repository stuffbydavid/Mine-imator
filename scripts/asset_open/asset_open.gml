/// asset_open([filename])
/// @arg [filename]
/// @desc Adds a file to the project.
///		  A file browser appears if no filename is given.

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

if (fn = "")
	return false

var ext = filename_ext(fn);
if (ext = ".zip") // Unzip
{
	var name, validfile;
	name = filename_new_ext(filename_name(fn), "")
	unzip(fn)
	
	// Look for pack
	if (directory_exists_lib(unzip_directory + "assets"))
	{
		action_res_pack_load(fn)
		return false
	}
	
	// Look for project
	validfile = file_find_single(unzip_directory, "miproj;.mproj;.mani")
	if (!file_exists_lib(validfile))
		validfile = file_find_single(unzip_directory + name + "\\", "miproj;.mproj;.mani")
	
	// Look for object
	if (!file_exists_lib(validfile))
		validfile = file_find_single(unzip_directory, "miobj;mipart;.object;.particles;")
	if (!file_exists_lib(validfile))
		validfile = file_find_single(unzip_directory + name + "\\", "miobj;mipart;.object;.particles;")
	
	// Pack?
	if (!file_exists_lib(validfile))
	{
		error("erroropenassetzip")
		return false
	} 
	else
	{
		fn = validfile
		ext = filename_ext(fn)
	}
}

if (!file_exists_lib(fn))
	return false

switch (ext)
{
	case ".miframes":
	case ".keyframes":
		log("Opening keyframes", fn)
		//action_tl_keyframes_load(fn)
		return true
	
	case ".schematic":
	case ".blocks":
		log("Opening schematic", fn)
		action_lib_scenery_load(fn)
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
		
	case ".png":
	case ".jpg":
		log("Opening image", fn)
		popup_importimage.filename = fn
		popup_show(popup_importimage)
		return true
		
	// TODO .mimodel
	// TODO .json model
}

log("Opening asset", fn)

// Post 1.1.0 (JSON)
if (string_contains(filename_ext(fn), ".miproj"))
{
	log("Opening project", fn)
	var rootmap = project_load_start(fn);
	if (rootmap = null)
		return false
}

// Pre 1.1.0 (buffer)
else
{
	log("Opening legacy project", fn)
	if (!project_load_legacy_start(fn))
		return false
}

var hobj = null;
if (!history_redo)
	hobj = history_set(asset_open)

project_reset_loaded()

save_folder = project_folder
load_folder = filename_dir(fn)
log("save_folder", save_folder)
log("load_folder", load_folder)

switch (ext)
{
	// Object
	case ".miobj":
	{
	
	}
	case ".object":
	{
		log("Opening legacy object")
		
		project_load_legacy_objects()
		project_load_find_save_ids()
		project_load_update()
		break
	}
		
	// Particle spawner
	case ".particles":
	{
		log("Opening particles")
		
		var temp = new(obj_template);
		with (temp)
		{
			loaded = true
			sortlist_add(other.lib_list, id)
			type = "particles"
			project_load_legacy_particles()
		}
		project_load_legacy_objects()
		project_load_find_save_ids()
		
		with (temp)
			with (temp_animate())
				loaded = true
				
		project_load_update()
		break
	}
	
	// Project
	case ".mproj":
	{
		log("Opening mproj")
		
		with (new(obj_dummy))
		{
			project_load_legacy_project()
			instance_destroy()
		}
		project_load_legacy_objects()
		project_load_find_save_ids()
		project_load_update()
		break
	}
	
	case ".mani":
	{
		log("Opening mani")
		project_load_legacy_beta()
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
