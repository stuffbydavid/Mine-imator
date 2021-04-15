/// project_load_markers(list)
/// @arg list

var list, markermap;
list = argument0

if (!ds_list_valid(list))
	return 0

for (var i = 0; i < ds_list_size(list); i++)
{
	markermap = list[|i]
	
	with (new(obj_marker))
	{
		loaded = true
		
		load_id = value_get_string(markermap[?"id"], save_id)
		save_id_map[?load_id] = load_id
		
		pos = value_get_real(markermap[?"position"], 0)
		name = value_get_string(markermap[?"name"], "")
		color = value_get_real(markermap[?"color"], 0)
	}
}
