/// project_load([filename])
/// @arg [filename]
/// @desc Opens a .miproj, .mproj, .mani project or zipped archive.
///		  A file browser appears if no filename is given.
///		  Formats:
///			project_01
///			project_02
///			project_05
///			project_06
///			project_07demo
///			project_100demo2
///			project_100demo3 = added hasX in timeline, removed count in library, added spawn_rate, spawn_region toggle in particle types
///			project_100demo4 = added ground_z in particles, has_background, removed text_system_font_*, camera rotation and ratio, block_ani, pars in timelines, timeline zoom, pos
///			project_100debug = shape hvoffset, map, closed, wind setting, char_model name, particle type iid, click->!lock, timeline depth, parent_pos, fog height, item_sheet, block_frames, new value types, shape face camera, timeline texture filtering & ssao, fog sky, render region
///			project_100 = timeline_repeat
///			project_105 = background_sunlight_follow
///			project_105_2 = timeline fog, timeline_marker
///			project_106 = new mobs
///			project_106_2 = camera size in keyframes
///			project_110 = redone in JSON

var fn;
if (argument_count > 0)
	fn = argument[0]
else
	fn = file_dialog_open_project()

if (fn = "")
	return 0

var name = filename_new_ext(filename_name(fn), "");

// If an archive is chosen, unzip it and look for valid projects
if (filename_ext(fn) = ".zip")
{
	unzip(fn)
	fn = file_find_single(unzip_directory, ".miproj;.mproj;.mani")
	if (!file_exists_lib(fn))
		fn = file_find_single(unzip_directory + name + "\\", ".miproj;.mproj;.mani")
	if (!file_exists_lib(fn))
	{
		error("erroropenprojectzip")
		return 0
	}
}

if (!file_exists_lib(fn))
	return 0

// Post 1.1.0 (JSON)
if (string_contains(filename_ext(fn), ".miproj"))
{
	log("Opening project", fn)
	var rootmap = project_load_start(fn);
	if (rootmap = null)
		return 0
}

// Pre 1.1.0 (buffer)
else
{
	log("Opening legacy project", fn)
	if (!project_load_legacy_start(fn))
		return 0
}

project_reset()
project_reset_loaded()

project_file = filename_new_ext(fn, ".miproj")
project_folder = filename_dir(fn)
project_name = name

save_folder = project_folder
load_folder = filename_dir(fn)
log("save_folder", save_folder)
log("load_folder", load_folder)

if (load_format >= e_project.FORMAT_110)
{
	project_load_project(rootmap[?"project"])
	project_load_background(rootmap[?"background"])
}

// Legacy
else
{
	if (load_format >= e_project.FORMAT_07_DEMO)
	{
		project_load_legacy_project()
		/*project_read_start()
		project_read_project()
		project_read_objects()
		project_read_background()
		project_read_camera()
		project_read_get_iids(false)*/
	}
	else
	{
		/*project_read_old(false)*/
	}

	buffer_delete(buffer_current)
}
	
// Update project
project_read_update()
log("Project loaded")

// Close popup
if (ds_priority_size(load_queue) = 0)
	popup_close()

if (load_format < e_project.FORMAT_110)
	project_save()

recent_add_wait = true