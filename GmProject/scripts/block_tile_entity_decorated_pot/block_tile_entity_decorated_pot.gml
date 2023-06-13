/// block_tile_entity_decorated_pot(map)
/// @arg map

function block_tile_entity_decorated_pot(map)
{
	var sherdsarr = map[?"sherds"];
	
	for (var i = 0; i < ds_list_size(sherdsarr); i++)
	{
		sherdsarr[|i] = string_replace(sherdsarr[|i], "minecraft:", "")
		
		if (sherdsarr[|i] = "brick")
			sherdsarr[|i] = "none"
		else
			sherdsarr[|i] = string_replace(sherdsarr[|i], "_pottery_sherd", "")
	}
	
	var state;
	state = block_set_state_id_value(block_current, block_state_id_current, "sherd_front", sherdsarr[|0]);
	state = block_set_state_id_value(block_current, state, "sherd_left", sherdsarr[|1]);
	state = block_set_state_id_value(block_current, state, "sherd_right", sherdsarr[|2]);
	state = block_set_state_id_value(block_current, state, "sherd_back", sherdsarr[|3]);
	
	builder_set_state_id(build_pos_x, build_pos_y, build_pos_z, state)
}
