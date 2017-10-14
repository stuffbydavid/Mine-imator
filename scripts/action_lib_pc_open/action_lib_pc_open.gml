/// action_lib_pc_open()

var fn = file_dialog_open_particles();
if (fn = "")
	return 0

particles_load(fn, temp_edit)
