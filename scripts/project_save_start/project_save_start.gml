/// project_save_start(filename, saveall)
/// @arg filename
/// @arg saveall

json_export_start(argument0)
json_export_object_start()
json_export_var("format", project_format)

with (obj_template)
	save = argument1
	
with (obj_timeline)
	save = argument1
	
with (obj_resource)
	save = argument1
