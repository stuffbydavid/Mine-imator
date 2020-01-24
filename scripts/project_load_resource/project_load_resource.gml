/// project_load_resource(map)
/// @arg map

var map = argument0;

if (!ds_map_valid(map))
	return 0

with (new(obj_resource))
{
	loaded = true
	load_id = value_get_string(map[?"id"], save_id)
	save_id_map[?load_id] = load_id
	
	type = ds_list_find_index(res_type_name_list, value_get_string(map[?"type"]))
	filename = value_get_string(map[?"filename"], filename)
	
	if (type = e_res_type.SKIN || type = e_res_type.DOWNLOADED_SKIN)
		player_skin = value_get_real(map[?"player_skin"], player_skin)
	
	if (type = e_res_type.ITEM_SHEET)
		item_sheet_size = value_get_point2D(map[?"item_sheet_size"], item_sheet_size)
		
	if (type = e_res_type.SCHEMATIC)
	{
		scenery_tl_add = value_get_real(map[?"scenery_tl_add"], true)
		scenery_download_skins = value_get_real(map[?"scenery_download_skins"], false)
	}
	
	sortlist_add(app.res_list, id)
}