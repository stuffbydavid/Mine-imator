/// particles_save()
/// @desc Export the selected library's particle creator.

var fn = file_dialog_save_particles(temp_edit.display_name);

if (fn = "")
	return 0
	
fn = filename_new_ext(fn, ".miparticles")

log("Saving particles", fn)

save_folder = filename_dir(fn)
load_folder = project_folder
log("save_folder", save_folder)
log("load_folder", load_folder)

project_save_start(fn, false)

with (temp_edit)
	project_save_particles()
	
project_save_objects()
project_save_done()

log("Particles saved")
