/// project_load([filename])
/// @arg [filename]
/// @desc Opens a .miproject, .mproj, .mani project or zipped archive.
/// A file browser appears if no filename is given.
///		Formats:
///			0.1
///			0.2
///			0.5
///			0.6
///			0.7 DEMO
///			1.0.0 DEMO 2
///			1.0.0 DEMO 3 = added hasX in timeline, removed count in library, added spawn_rate, spawn_region toggle in particle types
///			1.0.0 DEMO 4 = added ground_z in particles, has_background, removed text_system_font_*, camera rotation and ratio, block_ani, pars in timelines, timeline zoom, pos
///			1.0.0 debug = shape hvoffset, map, closed, wind setting, char_model name, particle type iid, click->!lock, timeline depth, parent_pos, fog height, item_sheet, block_frames, new value types, shape face camera, timeline texture filtering & ssao, fog sky, render region
///			1.0.0 = timeline_repeat
///			1.0.5 = background_sunlight_follow
///			1.0.5 2 = timeline fog, timeline_marker
///			1.0.6 = new mobs
///			1.0.6 2 = camera size in keyframes
///			1.1.0 PRE 1 = redone in JSON

function project_load()
{
	var fn = (argument_count > 0 ? argument[0] : file_dialog_open_project())
	
	if (fn = "")
		return 0
	
	var name = filename_new_ext(filename_name(fn), "");
	
	// If an archive is chosen, unzip it and look for valid projects
	if (filename_ext(fn) = ".zip")
	{
		unzip(fn)
		fn = file_find_single(unzip_directory, ".miproject;.mproj;.mani")
		if (!file_exists_lib(fn))
			fn = file_find_single(unzip_directory + name + "/", ".miproject;.mproj;.mani")
		if (!file_exists_lib(fn))
		{
			error("erroropenprojectzip")
			return 0
		}
	}
	
	if (!file_exists_lib(fn))
		return 0
	
	// Post 1.1.0 (JSON)
	var ext, rootmap, legacy, buf;
	ext = filename_ext(fn)
	if (ext = ".miproject" || string_contains(ext, ".backup"))
	{
		log("Opening project", fn)
		rootmap = project_load_start(fn)
		if (rootmap = null)
			return 0
		
		legacy = false
	}
	
	// Pre 1.1.0 (buffer)
	else
	{
		log("Opening legacy project", fn)
		if (!project_load_legacy_start(fn))
			return 0
		
		buf = buffer_current
		legacy = true
	}
	
	project_reset()
	project_reset_loaded()
	
	project_file = filename_new_ext(fn, ".miproject")
	project_folder = filename_dir(fn)
	project_name = name
	
	save_folder = project_folder
	load_folder = filename_dir(fn)
	log("save_folder", save_folder)
	log("load_folder", load_folder)
	
	if (!legacy)
	{
		project_load_project(rootmap[?"project"])
		project_load_render(rootmap[?"render"])
		project_load_background(rootmap[?"background"])
		project_load_objects(rootmap)
		project_load_markers(rootmap[?"markers"])
	}
	else
	{
		buffer_current = buf
		if (load_format >= e_project.FORMAT_100_DEMO_2)
		{
			project_load_legacy_project()
			project_load_legacy_objects()
			project_load_legacy_background()
			project_load_legacy_work_camera()
		}
		else
			project_load_legacy_beta(true)
		
		buffer_delete(buffer_current)
	}
	
	// Update project
	project_load_find_save_ids()
	project_load_update()
	project_reset_loaded()
	log("Project loaded")
	
	// Save into newest format
	if (load_format < e_project.FORMAT_110_PRE_1)
	{
		if (!dev_mode)
			file_rename_lib(fn, fn + ".old")
		project_save()
	}
	
	recent_add_wait = true
	return true
}
