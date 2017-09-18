/// project_save_resource()

json_save_object_start()

	json_save_var("id", save_id)
	json_save_var("type", type)
	json_save_var("filename", json_string_encode(filename))
	
	if (type = "skin" || type = "downloadskin")
		json_save_var_bool("player_skin", player_skin)
	
	if (type = "itemsheet")
		json_save_var_point2D("item_sheet_size", item_sheet_size)
		
	if (load_folder != save_folder)
		res_save()

json_save_object_done()