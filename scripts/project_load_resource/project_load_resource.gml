/// project_load_resource(map)
/// @arg map

var map = argument0;

if (!ds_exists(map, ds_type_map))
	return 0

with (new(obj_resource))
{
	loaded = true
	
	sortlist_add(app.res_list, id)
	
	load_id = json_read_string(map[?"id"], save_id)
	save_id_map[?load_id] = load_id
	
	type = json_read_string(map[?"type"], type)
	filename = json_read_string(map[?"filename"], filename)
	
	if (type = "skin" || type = "downloadskin")
		player_skin = json_read_real(map[?"player_skin"], player_skin)
	
	if (type = "itemsheet")
		item_sheet_size = json_read_array(map[?"item_sheet_size"], item_sheet_size)
}