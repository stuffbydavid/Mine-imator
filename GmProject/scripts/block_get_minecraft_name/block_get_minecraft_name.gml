/// @desc Returns the Minecraft name matching a selected block variant.
/// @arg block
/// @arg stateid

function block_get_minecraft_name(block, stateid)
{
	if (block.id_state_vars_map != null)
	{
		var key = ds_map_find_first(block.id_state_vars_map);
		while (!is_undefined(key))
		{
			if (state_vars_match_state_id(block.id_state_vars_map[?key], block, stateid))
				return string_replace(key, "minecraft:", "")
			
			key = ds_map_find_next(block.id_state_vars_map, key)
		}
	}
	
	if (array_length(block.mc_ids) > 0)
		return block.mc_ids[0]

	return block.name
}
