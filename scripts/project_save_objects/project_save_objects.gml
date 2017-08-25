/// project_save_objects()

json_export_array_start("templates")
with (obj_template)
	if (save)
		project_save_template()
json_export_array_done()
		
json_export_array_start("timelines")
with (obj_timeline)
	if (save)
		project_save_timeline()
json_export_array_done()
		
json_export_array_start("resources")
with (obj_resource)
	if (save && id != res_def)
		project_save_resource()
json_export_array_done()