/// debug_ds_map(map)
/// @arg map

var map, key;
map = argument0
key = ds_map_find_first(map)

log("Elements", ds_map_size(map))
while (!is_undefined(key))
{
	log("   " + string(key) + " => " + string(map[?key]))
	key = ds_map_find_next(map, key)
}