/// project_open(filename)
/// @arg filename
/// @desc Open .mproj, .mani or .zip
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
/*
var fn, name, buf;
fn = argument0

if (fn = "")
	fn = file_dialog_open_project()
if (fn = "")
	return 0

name = filename_new_ext(filename_name(fn), "")

if (filename_ext(fn) = ".zip") // Unzip
{
	zip_import(fn)
	fn = file_find_single(unzip_directory, ".mproj;.mani")
	if (!file_exists_lib(fn))
		fn = file_find_single(unzip_directory + name + "\\", ".mproj;.mani")
	if (!file_exists_lib(fn))
	{
		error("erroropenprojectzip")
		return 0
	}
}

if (!file_exists_lib(fn))
	return 0

log("Opening project", fn)

buffer_current = buffer_import(fn)
load_folder = filename_dir(fn)
load_format = buffer_read_byte()
log("load_folder", load_folder)
log("load_format", load_format)

if (load_format > project_format) // Too new
{
	log("Too new")
	error("erroropenprojectnewer")
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

project_reset()

project_file = filename_new_ext(fn, ".mproj")
project_folder = filename_dir(fn)
project_name = name

save_folder = project_folder
log("save_folder", save_folder)

if (load_format > project_07demo)
{
	project_read_start()
	project_read_project()
	project_read_objects()
	project_read_background()
	project_read_camera()
	project_read_get_iids(false)
}
else
	project_read_old(false)

project_read_update()
buffer_delete(buffer_current)

log("Project loaded")

// Close popup
if (ds_priority_size(load_queue) = 0)
	popup_close()

if (load_format < project_100demo2)
	project_save("")

recent_add_wait = true
*/