/// project_load_resource(map)
/// @arg map

function project_load_resource(argument0)
{
	var map = argument0;
	
	if (!ds_map_valid(map))
		return 0
	
	with (new_obj(obj_resource))
	{
		loaded = true
		load_id = value_get_string(map[?"id"], save_id)
		save_id_map[?load_id] = load_id
		
		var typestr = value_get_string(map[?"type"]);
		
		if (load_format < e_project.FORMAT_130_AL9)
		{
			if (typestr = "schematic")
				typestr = "scenery"
		}
		
		type = ds_list_find_index(res_type_name_list, typestr)
		
		filename = value_get_string(map[?"filename"], filename)
		
		if (type = e_res_type.SKIN || type = e_res_type.DOWNLOADED_SKIN)
			player_skin = value_get_real(map[?"player_skin"], player_skin)
		
		if (type = e_res_type.ITEM_SHEET)
			item_sheet_size = value_get_point2D(map[?"item_sheet_size"], item_sheet_size)
		
		if (type = e_res_type.SCENERY)
		{
			scenery_tl_add = value_get_real(map[?"scenery_tl_add"], true)
			scenery_download_skins = value_get_real(map[?"scenery_download_skins"], false)
			
			scenery_palette = value_get_real(map[?"scenery_palette"], scenery_palette)
			scenery_integrity = value_get_real(map[?"scenery_integrity"], scenery_integrity)
			scenery_integrity_invert = value_get_real(map[?"scenery_integrity_invert"], scenery_integrity_invert)
		}
		
		sortlist_add(app.res_list, id)
	}
}
