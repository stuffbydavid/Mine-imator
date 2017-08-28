/// asset_open(filename)
/// @arg filename
/// @desc Adds a file to the project.
/* TODO
var fn, hobj;
hobj = null

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
	fn = argument0

if (filename_ext(fn) = ".zip") // Unzip
{
	var name, validfile;
	name = filename_new_ext(filename_name(fn), "")
	unzip(fn)
	
	// Look for pack
	validfile = file_find_single(unzip_directory, ".mcmeta")
	if (file_exists_lib(validfile))
	{
		action_res_pack_load(fn)
		return false
	}
	
	// Look for project
	validfile = file_find_single(unzip_directory, ".mproj;.mani")
	if (!file_exists_lib(validfile))
		validfile = file_find_single(unzip_directory + name + "\\", ".mproj;.mani")
	
	// Look for object
	if (!file_exists_lib(validfile))
		validfile = file_find_single(unzip_directory, ".object;.particles;")
	if (!file_exists_lib(validfile))
		validfile = file_find_single(unzip_directory + name + "\\", ".object;.particles;")
	
	// Pack?
	if (!file_exists_lib(validfile))
	{
		if (question(text_get("questionzip")))
			action_res_pack_load(fn)
		return false
	} 
	else
		fn = validfile
}

if (!file_exists_lib(fn))
	return false

var ext = filename_ext(fn);
switch (ext)
{
	case ".keyframes":
		log("Opening keyframes", fn)
		action_tl_keyframes_load(fn)
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
}

if (!history_redo)
{
	hobj = history_set(asset_open)
	hobj.filename = fn
}

log("Opening asset", fn)
		
buffer_current = buffer_load_lib(fn)
load_folder = filename_dir(fn)
load_format = buffer_read_byte()
save_folder = project_folder
log("load_folder", load_folder)
log("load_format", load_format)
log("save_folder", load_format)

if (load_format > project_format)
{
	log("Too new")
	error("erroropenassetnewer")
	buffer_delete(buffer_current)
	return 0
}
else if (load_format < project_05) // Too old
{
	log("Too old")
	error("errorfilecorrupted")
	buffer_delete(buffer_current)
	return 0
}

switch (ext)
{
	case ".object":
		log("Opening object")
		project_read_start()
		project_read_objects()
		project_read_get_iids(true)
		break
		
	case ".particles":
		var temp, tl;
		log("Opening particles")
		project_read_start()
		temp = new(obj_template)
		temp.loaded = true
		with (temp)
		{
			load_iid_offset++
			type = "particles"
			project_read_particles()
		}
		project_read_objects()
		project_read_get_iids(true)
		with (temp)
			tl = temp_animate()
		tl.loaded = true
		sortlist_add(lib_list, temp)
		break
		
	case ".mproj":
		log("Opening mproj")
		project_read_start()
		with (new(obj_dummy))
		{
			project_read_project()
			instance_destroy()
		}
		project_read_objects()
		project_read_get_iids(true)
		break
		
	case ".mani":
		log("Opening mani")
		project_read_old(true)
		break
}

with (hobj)
	history_save_loaded()

project_read_update()
buffer_delete(buffer_current)

log("Asset loaded")

return true*/
