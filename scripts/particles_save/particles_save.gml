/// particles_save()
/// @desc Export the selected library's particle creator.

function particles_save()
{
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
	
	// Save path points
	if (temp_edit.pc_spawn_region_type = "path" && temp_edit.pc_spawn_region_path != null)
	{
		var tl = temp_edit.pc_spawn_region_path;
		for (var i = 0; i < ds_list_size(tl.tree_list); i++)
		{
			if (tl.tree_list[|i].type = e_tl_type.PATH_POINT)
				tl.tree_list[|i].save = true
		}
	}
	
	project_save_objects()
	project_save_done()
	
	log("Particles saved")
}
