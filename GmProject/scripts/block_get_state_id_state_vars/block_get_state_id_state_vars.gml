function block_get_state_id_state_vars(block, stateid)
{
	var vars = [];
	
	if (block.states_map != null)
	{
		var key, i, val;
		key = ds_map_find_first(block.states_map)
		i = 0
		while (!is_undefined(key))
		{
			val = block_get_state_id_value(block, stateid, block.states_map[?key].name)
			// Normal blocks omit visibility; hidden cells retain it for save/load
			if (key != "visible" || !block.tl_mesh || val != "true")
			{
				vars[i * 2] = block.states_map[?key].name
				vars[i * 2 + 1] = val
				i++
			}

			key = ds_map_find_next(block.states_map, key)
		}
	}
	
	return vars
}
