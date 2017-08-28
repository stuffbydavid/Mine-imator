/// project_load_values(map, array)
/// @arg map
/// @arg array

var map, arr, key;
map = argument0
arr = argument1

key = ds_map_find_first(map)
while (!is_undefined(key))
{
	var index = ds_list_find_index(value_name_list, key);
	if (index >= 0)
		arr[@ index] = map[?key]
		
	key = ds_map_find_next(map, key)
}