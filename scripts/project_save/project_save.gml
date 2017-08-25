/// project_save(filename)
/// @arg filename

var fn = argument0;

if (fn = "")
	fn = project_file
	
if (fn = "")
	return 0
	
log("Saving project", fn)
	
save_folder = project_folder
load_folder = project_folder
log("load_folder", load_folder)
log("save_folder", save_folder)

log("timelines",instance_number(obj_timeline))
log("keyframes",instance_number(obj_keyframe))
debug_timer_start()
project_save_start(fn, true)
project_save_project()
project_save_background()
project_save_objects()
project_save_done()
debug_timer_stop("project_save")

log("Project saved")

project_changed = false
recent_add_wait = true
