/// project_save_resource()

function project_save_resource()
{
	json_save_object_start()
		
		json_save_var("id", save_id)
		json_save_var("type", res_type_name_list[|type])
		json_save_var("filename", json_string_encode(filename))
		
		if (type = e_res_type.SKIN || type = e_res_type.DOWNLOADED_SKIN)
			json_save_var_bool("player_skin", player_skin)
		
		if (type = e_res_type.ITEM_SHEET)
			json_save_var_point2D("item_sheet_size", item_sheet_size)
		
		if (type = e_res_type.SCENERY || type = e_res_type.FROM_WORLD)
		{
			json_save_var_bool("scenery_tl_add", scenery_tl_add)
			json_save_var_bool("scenery_download_skins", scenery_download_skins)
		}
		
		if (type = e_res_type.SCENERY)
		{
			json_save_var("scenery_palette", scenery_palette)
			json_save_var("scenery_integrity", scenery_integrity)
			json_save_var_bool("scenery_integrity_invert", scenery_integrity_invert)
		}
		
		if (type = e_res_type.FROM_WORLD)
		{
			json_save_var("world_regions_dir", json_string_encode(world_regions_dir))
			json_save_var_point3D("world_box_start", world_box_start)
			json_save_var_point3D("world_box_end", world_box_end)
			json_save_var("world_filter_mode", world_filter_mode)
			json_save_array_start("world_filter_array")
			for (var i = 0; i < array_length(world_filter_array); i++)
				json_save_array_value(world_filter_array[i])
			json_save_array_done()
		}
		
		json_save_var_bool("uses_glossiness", material_uses_glossiness)
		
		if (load_folder != save_folder)
			res_save()
	
	json_save_object_done()
}
