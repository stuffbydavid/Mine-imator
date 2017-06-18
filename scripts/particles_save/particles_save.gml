/// particles_save()
/// @desc Export the selected library's particle creator.

var fn = file_dialog_save_particles(temp_edit.display_name);

if (fn = "")
    return 0
    
fn = filename_new_ext(fn, ".particles")

log("Saving particles", fn)

project_write_start(false)
load_folder = project_folder
save_folder = filename_dir(fn)
log("load_folder", load_folder)
log("save_folder", save_folder)

with (temp_edit)
    project_write_particles()
project_write_objects()

buffer_export(buffer_current, fn)
buffer_delete(buffer_current)

log("Particles saved")
