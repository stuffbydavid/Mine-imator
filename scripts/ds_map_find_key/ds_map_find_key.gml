/// ds_map_find_key(map, value)
/// @arg map
/// @arg value

function ds_map_find_key(map, val)
{
	var key = ds_map_find_first(map);
	while (!is_undefined(key))
	{
		if (map[?key] = val)
			return key
		key = ds_map_find_next(map, key)
	}
	
	return undefined
}
