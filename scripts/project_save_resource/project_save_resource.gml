/// project_save_resource()

json_save_object_start()

	json_save_var("id", save_id)
	json_save_var("type", res_type_name_list[|type])
	json_save_var("filename", json_string_encode(filename))
	
	if (type = e_res_type.SKIN || type = e_res_type.DOWNLOADED_SKIN)
		json_save_var_bool("player_skin", player_skin)
	
	if (type = e_res_type.ITEM_SHEET)
		json_save_var_point2D("item_sheet_size", item_sheet_size)
		
	if (load_folder != save_folder)
		res_save()

json_save_object_done()