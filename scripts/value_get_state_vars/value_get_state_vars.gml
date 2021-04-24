/// value_get_state_vars(map)
/// @arg map

function value_get_state_vars(map)
{
	var vars, varslen;
	vars = array()
	varslen = 0
	
	if (ds_map_valid(map))
	{
		var key = ds_map_find_first(map);
		while (!is_undefined(key))
		{
			vars[varslen++] = key
			vars[varslen++] = map[?key]
			key = ds_map_find_next(map, key)
		}
	}
	
	return vars
}
