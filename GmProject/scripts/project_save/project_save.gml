/// project_save([filename])
/// @arg [filename]

function project_save()
{
	var fn = (argument_count > 0 ? argument[0] : project_file)
	
	log("Saving project", fn)
	
	save_folder = project_folder
	load_folder = project_folder
	log("save_folder", save_folder)
	log("load_folder", load_folder)
	
	debug_timer_start()
	
	project_save_start(fn, true)
	project_save_project()
	project_save_render()
	project_save_background()
	project_save_objects()
	project_save_markers()
	project_save_done()
	
	debug_timer_stop("project_save")
	log("Project saved")
	
	if (!string_contains(filename_ext(fn), "backup"))
	{
		project_changed = false
		recent_add_wait = true
	}
}
