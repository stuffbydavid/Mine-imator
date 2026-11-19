/// @desc Resolve a schematic palette entry.

function builder_read_block_state(state)
{
	var mcid, prop, vars;
	prop = null
	vars = []
	
	if (is_string(state))
	{
		var bracket = string_pos("[", state);
		mcid = state
		
		if (bracket > 0)
		{
			mcid = string_copy(state, 1, bracket - 1)
			prop = string_get_state_vars(string_copy(state, bracket + 1, string_length(state) - bracket - 1))
		}
	}
	else if (ds_map_valid(state))
	{
		mcid = state[?"Name"]
		if (!is_string(mcid))
			mcid = state[?"name"]
		
		prop = state[?"Properties"]
		if (!ds_map_valid(prop))
			prop = state[?"properties"]
	}
	else
		return [ null, 0, false ]

	if (!is_string(mcid))
		return [ null, 0, false ]
	
	if (string_pos(":", mcid) = 0)
		mcid = "minecraft:" + mcid

	var block = mc_assets.block_id_map[?mcid];
	if (is_undefined(block) || block = null)
		return [ null, 0, false ]

	// Apply identifier defaults before explicit properties
	if (block.id_state_vars_map != null && is_array(block.id_state_vars_map[?mcid]))
		state_vars_add(vars, block.id_state_vars_map[?mcid])
	
	if (is_array(prop))
		state_vars_add(vars, prop)
	else if (ds_map_valid(prop))
	{
		var pairs, key;
		pairs = []
		key = ds_map_find_first(prop)
		
		while (!is_undefined(key))
		{
			if (!string_contains(key, "_NBT_"))
			{
				array_add(pairs, key)
				array_add(pairs, prop[?key])
			}
			
			key = ds_map_find_next(prop, key)
		}
		
		state_vars_add(vars, pairs)
	}

	var waterlogged = state_vars_get_value(vars, "waterlogged");
	return [
		block,
		block_get_state_id(block, vars),
		waterlogged != "false" && (block.waterlogged || waterlogged = "true")
	]
}
