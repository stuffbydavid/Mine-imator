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
		
		if (type = e_res_type.FROM_WORLD)
		{
			json_save_var("world_name", json_string_encode(world_name))
			json_save_var("world_regions_dir", json_string_encode(world_regions_dir))
			json_save_var_point3D("world_box_start", world_box_start)
			json_save_var_point3D("world_box_end", world_box_end)
		}
		
		if (type = e_res_type.SCHEMATIC || type = e_res_type.FROM_WORLD)
		{
			json_save_var_point3D("scenery_size", scenery_size)

			if (scenery_tl_all_types)
				json_save_var_bool("scenery_tl_all_types", true)

			json_save_array_start("scenery_tl_types")

			for (var i = 0; i < array_length(scenery_tl_types); i++)
				json_save_array_value(scenery_tl_types[i])

			json_save_array_done()

			json_save_object_start("scenery_block_map")

			var key = ds_map_find_first(scenery_block_map);
			while (!is_undefined(key))
			{
				json_save_var(string(key), scenery_block_map[?key])
				key = ds_map_find_next(scenery_block_map, key)
			}

			json_save_object_done()

			if (scenery_tl_types_count_ready)
			{
				json_save_object_start("scenery_tl_types_count_map")

				key = ds_map_find_first(scenery_tl_types_count_map)
				while (!is_undefined(key))
				{
					json_save_var(string(key), scenery_tl_types_count_map[?key])
					key = ds_map_find_next(scenery_tl_types_count_map, key)
				}

				json_save_object_done()
			}

			json_save_var_bool("scenery_filter_enabled", scenery_filter_enabled)
			json_save_var("scenery_filter_mode", scenery_filter_mode)

			json_save_array_start("scenery_filter_array")
			for (var i = 0; i < array_length(scenery_filter_array); i++)
				json_save_array_value(scenery_filter_array[i])
			json_save_array_done()

			json_save_var_bool("scenery_download_skins", scenery_download_skins)

			if (scenery_cache_save != null)
				json_save_var_bool("scenery_cache_save", scenery_cache_save)
		}
		
		if (type = e_res_type.SCHEMATIC)
		{
			json_save_var_bool("scenery_structure", scenery_structure)
			json_save_var("scenery_integrity", scenery_integrity)
			json_save_var("scenery_palette_size", scenery_palette_size)
			json_save_var("scenery_palette", scenery_palette)
			json_save_var_bool("scenery_randomize", scenery_randomize)
		}
		
		if (type = e_res_type.SOUND && minecraft_hash != "")
			json_save_var("minecraft_hash", minecraft_hash)
		
		if (material_format != e_material.FORMAT_LABPBR)
			json_save_var("material_format", material_format)
		
		if (load_folder != save_folder)
			res_save()
	
	json_save_object_done()
}
