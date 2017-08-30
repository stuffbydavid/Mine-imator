/// project_load_resource(map)
/// @arg map

var map = argument0;

if (!ds_exists(map, ds_type_map))
	return 0

with (new(obj_resource))
{
	loaded = true
	
	sortlist_add(app.res_list, id)
	
	save_id = json_read_string(map[?"id"], save_id)
	save_id_map[?save_id] = save_id
	
	type = json_read_string(map[?"type"], type)
	filename = json_read_string(map[?"filename"], filename)
	
	if (type = "skin" || type = "downloadskin")
		is_skin = json_read_real("is_skin", is_skin)
	
	if (type = "itemsheet")
		item_sheet_size = json_read_array("item_sheet_size", item_sheet_size)
}