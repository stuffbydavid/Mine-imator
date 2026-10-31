function project_load_resource(map)
{
	if (!ds_map_valid(map))
		return 0
	
	with (new_obj(obj_resource))
	{
		loaded = true
		load_id = value_get_string(map[?"id"], save_id)
		save_id_map[?load_id] = load_id
		
		var typestr = value_get_string(map[?"type"]);
		
		// Pre-2.1 schematic resources
		if (typestr = "scenery")
			typestr = "schematic"
		
		if (ds_map_exists(legacy_type_name_map, typestr))
			typestr = legacy_type_name_map[?typestr]
		
		type = ds_list_find_index(res_type_name_list, typestr)
		
		filename = value_get_string(map[?"filename"], filename)
		
		if (type = e_res_type.SKIN || type = e_res_type.DOWNLOADED_SKIN)
			player_skin = value_get_real(map[?"player_skin"], player_skin)
		
		if (type = e_res_type.ITEM_SHEET)
			item_sheet_size = value_get_point2D(map[?"item_sheet_size"], item_sheet_size)
		
		if (type = e_res_type.FROM_WORLD)
		{
			world_name = value_get_string(map[?"world_name"], filename)
			if (load_format < e_project.FORMAT_210)
				world_name = filename

			world_regions_dir = value_get_string(map[?"world_regions_dir"])
			world_box_start = value_get_point3D(map[?"world_box_start"])
			world_box_end = value_get_point3D(map[?"world_box_end"])
		}
		
		if (type = e_res_type.SCHEMATIC || type = e_res_type.FROM_WORLD)
		{
			scenery_size = value_get_point3D(map[?"scenery_size"], vec3(0, 0, 0))
			
			if (load_format >= e_project.FORMAT_210)
			{
				var tltypeslist = map[?"scenery_tl_types"];
				if (ds_list_valid(tltypeslist))
				{
					for (var i = 0; i < ds_list_size(tltypeslist); i++)
						array_add(scenery_tl_types, tltypeslist[|i])
				}
				
				scenery_tl_all_types = value_get_real(map[?"scenery_tl_all_types"], scenery_tl_all_types)
			}
			else
				scenery_tl_all_types = value_get_real(map[?"scenery_tl_add"], scenery_tl_all_types)
			
			var blockmap = map[?"scenery_block_map"];
			if (ds_map_valid(blockmap))
				ds_map_copy(scenery_block_map, blockmap)
			
			var countsmap = map[?"scenery_tl_types_count_map"];
			if (ds_map_valid(countsmap))
			{
				ds_map_copy(scenery_tl_types_count_map, countsmap)
				scenery_tl_types_count_ready = true
			}
			
			scenery_tl_set = true

			var filterlist = null;
			if (load_format >= e_project.FORMAT_210)
			{
				scenery_filter_mode = value_get_real(map[?"scenery_filter_mode"], scenery_filter_mode)
				filterlist = map[?"scenery_filter_array"]
			}
			else if (type = e_res_type.FROM_WORLD) // Legacy world filter
			{
				scenery_filter_mode = value_get_real(map[?"world_filter_mode"], scenery_filter_mode)
				filterlist = map[?"world_filter_array"]
			}
			
			if (ds_list_valid(filterlist))
				for (var i = 0; i < ds_list_size(filterlist); i++)
					array_add(scenery_filter_array, filterlist[|i])
			
			scenery_filter_enabled = value_get_real(map[?"scenery_filter_enabled"], array_length(scenery_filter_array) > 0)
			
			scenery_download_skins = value_get_real(map[?"scenery_download_skins"], false)
		}
		
		if (type = e_res_type.SCHEMATIC)
		{
			scenery_structure = value_get_real(map[?"scenery_structure"], scenery_structure)
			scenery_integrity = value_get_real(map[?"scenery_integrity"], scenery_integrity)

			if (value_get_real(map[?"scenery_integrity_invert"], false))
				scenery_integrity = 1 - scenery_integrity

			scenery_palette_size = value_get_real(map[?"scenery_palette_size"], scenery_palette_size)
			scenery_palette = value_get_real(map[?"scenery_palette"], scenery_palette)
			
			if (load_format >= e_project.FORMAT_210)
				scenery_randomize = value_get_real(map[?"scenery_randomize"], scenery_randomize)
			else
				scenery_randomize = value_get_real(map[?"randomize"], scenery_randomize)
		}
		
		if (type = e_res_type.SOUND)
			minecraft_hash = value_get_string(map[?"minecraft_hash"], minecraft_hash)
		
		material_format = value_get_real(map[?"material_format"], material_format)
		
		res_add_lists()
	}
}
