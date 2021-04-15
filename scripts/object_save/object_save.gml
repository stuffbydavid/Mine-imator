/// object_save()
/// @desc Saves selected timelines.

var fn = file_dialog_save_object(filename_get_valid(list_item_value != null ? list_item_value.display_name : tl_edit.display_name));

if (fn = "")
	return 0

fn = filename_new_ext(fn, ".miobject")
log("Saving object", fn)

save_folder = filename_dir(fn)
load_folder = project_folder
log("save_folder", save_folder)
log("load_folder", load_folder)

project_save_start(fn, false)

// Save specific timeline
if (list_item_value != null && !list_item_value.selected)
{
	with (list_item_value)
		tl_save()
}
else // Save selected timelines
{
	with (obj_timeline)
		if (selected)
			tl_save()
}

project_save_objects()
project_save_done()

log("Object saved")
