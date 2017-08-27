/// project_save_resource()

json_export_object_start()

	json_export_var_save_id("id", save_id)
	json_export_var("type", type)
	json_export_var("filename", filename)
	
	if (type = "skin" || type = "downloadskin")
		json_export_var_bool("is_skin", is_skin)
	
	if (type = "itemsheet")
		json_export_var("item_sheet_size", item_sheet_size)
		
	if (load_folder != save_folder)
		res_save()

json_export_object_done()