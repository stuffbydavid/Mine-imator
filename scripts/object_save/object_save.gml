/// object_save()
/// @desc Saves selected timelines.

var fn = file_dialog_save_object(filename_valid(tl_edit.display_name));

if (fn = "")
    return 0

fn = filename_new_ext(fn, ".object")

log("Saving object", fn)

project_write_start(false)
save_folder = filename_dir(fn)
load_folder = project_folder

with (obj_timeline)
    if (select)
        tl_save()

project_write_objects()

buffer_export(buffer_current, fn)
buffer_delete(buffer_current)

log("Object saved")
