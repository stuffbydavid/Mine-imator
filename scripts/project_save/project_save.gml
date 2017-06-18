/// project_save(filename)
/// @arg filename

var fn = argument0;

if (fn = "")
    fn = project_file
    
if (fn = "")
    return 0
    
log("Saving project", fn)
    
project_write_start(true)
save_folder = project_folder
load_folder = project_folder
log("load_folder", load_folder)
log("save_folder", save_folder)

project_write_project()
project_write_objects()
project_write_background()
project_write_camera()

buffer_export(buffer_current, fn)
buffer_delete(buffer_current)

log("Project saved")

project_changed = false
recent_add_wait = true
