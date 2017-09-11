/// object_save()
/// @desc Saves selected timelines.

var fn = file_dialog_save_object(filename_get_valid(tl_edit.display_name));

if (fn = "")
	return 0

fn = filename_new_ext(fn, ".miobj")
log("Saving object", fn)

save_folder = filename_dir(fn)
load_folder = project_folder
log("save_folder", save_folder)
log("load_folder", load_folder)

project_save_start(fn, false)

with (obj_timeline)
	if (selected)
		tl_save()

project_save_objects()
project_save_done()

log("Object saved")
