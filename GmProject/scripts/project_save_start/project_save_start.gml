/// project_save_start(filename, saveall)
/// @arg filename
/// @arg saveall

function project_save_start(fn, saveall)
{
	json_save_start(fn)
	json_save_object_start()
	json_save_var("format", project_format)
	json_save_var("created_in", mineimator_version_full)
	
	with (obj_template)
		save = saveall
	
	with (obj_timeline)
		save = saveall
	
	with (obj_resource)
		save = saveall
}
