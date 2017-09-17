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
	
	type = value_get_string(map[?"type"], type)
	filename = value_get_string(map[?"filename"], filename)
	
	if (type = "skin" || type = "downloadskin")
		player_skin = value_get_real(map[?"player_skin"], player_skin)
	
	if (type = "itemsheet")
		item_sheet_size = value_get_array(map[?"item_sheet_size"], item_sheet_size)
	
	sortlist_add(app.res_list, id)
}