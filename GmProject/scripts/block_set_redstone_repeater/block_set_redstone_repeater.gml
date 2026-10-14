/// @desc Set locked state.

function block_set_redstone_repeater()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0
	
	if (block_get_state_id_value(block_current, block_state_id_current, "locked") = "true")
		return 0
	
	var facing, locked;
	facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
	locked = "false"
	
	if (!build_edge[XP] && (facing = "south" || facing = "north"))
	{
		var block = builder_get_block(build_pos[X] + 1, build_pos[Y], build_pos[Z]);
		if (block != null && block.name = "powered_repeater")
		{
			var stateid = builder_get_state_id(build_pos[X] + 1, build_pos[Y], build_pos[Z]);
			if (block_get_state_id_value(block, stateid, "facing") = "east")
				locked = "true"
		}
	}
	
	if (locked = "false" && !build_edge[XN] && (facing = "south" || facing = "north"))
	{
		var block = builder_get_block(build_pos[X] - 1, build_pos[Y], build_pos[Z]);
		if (block != null && block.name = "powered_repeater")
		{
			var stateid = builder_get_state_id(build_pos[X] - 1, build_pos[Y], build_pos[Z]);
			if (block_get_state_id_value(block, stateid, "facing") = "west")
				locked = "true"
		}
	}
	
	if (locked = "false" && !build_edge[YP] && (facing = "east" || facing = "west"))
	{
		var block = builder_get_block(build_pos[X], build_pos[Y] + 1, build_pos[Z]);
		if (block != null && block.name = "powered_repeater")
		{
			var stateid = builder_get_state_id(build_pos[X], build_pos[Y] + 1, build_pos[Z]);
			if (block_get_state_id_value(block, stateid, "facing") = "south")
				locked = "true"
		}
	}
	
	if (locked = "false" && !build_edge[YN] && (facing = "east" || facing = "west"))
	{
		var block = builder_get_block(build_pos[X], build_pos[Y] - 1, build_pos[Z]);
		if (block != null && block.name = "powered_repeater")
		{
			var stateid = builder_get_state_id(build_pos[X], build_pos[Y] - 1, build_pos[Z]);
			if (block_get_state_id_value(block, stateid, "facing") = "north")
				locked = "true"
		}
	}
	
	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "locked", locked)
	
	return 0
}
