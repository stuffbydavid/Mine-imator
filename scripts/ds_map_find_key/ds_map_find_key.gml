/// ds_map_find_key(map, value)
/// @arg map
/// @arg value

var map, val, key;
map = argument0
val = argument1

key = ds_map_find_first(map)
while (!is_undefined(key))
{
	if (map[?key] = val)
		break
	key = ds_map_find_next(map, key)
}

return key