/// block_tile_entity_decorated_pot(map)
/// @arg map

function block_tile_entity_decorated_pot(map)
{
	var sherdsarr = map[?"sherds"];
	
	if (ds_list_valid(sherdsarr))
	{
		for (var i = 0; i < ds_list_size(sherdsarr); i++)
		{
			var sherd = sherdsarr[|i];
		
			if (minecraft_sherd_map[?sherd] != undefined)
				sherdsarr[|i] = minecraft_sherd_map[?sherd]
			else
				sherdsarr[|i] = "none"
		}
	}
	else
	{
		sherdsarr = ds_list_create()
		for (var i = 0; i < 4; i++)
			sherdsarr[|i] = "none"
	}
	
	var state = [];
	array_add(state, ["sherd_front", sherdsarr[|0]]);
	array_add(state, ["sherd_left", sherdsarr[|1]]);
	array_add(state, ["sherd_right", sherdsarr[|2]]);
	array_add(state, ["sherd_back", sherdsarr[|3]]);
	
	array_add(state, block_get_state_id_state_vars(block_current, block_state_id_current))
	
	mc_builder.block_decorated_pot_sherds_map[?build_pos] = state
}
