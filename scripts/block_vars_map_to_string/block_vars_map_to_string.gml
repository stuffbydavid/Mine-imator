/// block_vars_map_to_string(map)
/// @arg map

var map, vars, key;
map = argument0

vars = ""
key = ds_map_find_first(map)

while (!is_undefined(key))
{
	if (vars != "")
		vars += ","
		
	vars += key + "=" + map[?key]
	key = ds_map_find_next(map, key)
}

return vars