/// @desc Locates non-air blocks.

function block_set_fire()
{
	if (!builder_scenery_legacy)
		return 0
	
	var east, west, south, north, up, variant;
	east = "false"
	west = "false"
	south = "false"
	north = "false"
	up = "false"
	variant = block_get_state_id_value(block_current, block_state_id_current, "variant")
	
	if (!build_edge[XP])
	{
		var block = builder_get_block(build_pos[X] + 1, build_pos[Y], build_pos[Z]);
		if (block != null && block != block_current)
			east = "true"
	}
	
	if (!build_edge[XN])
	{
		var block = builder_get_block(build_pos[X] - 1, build_pos[Y], build_pos[Z]);
		if (block != null && block != block_current)
			west = "true"
	}
	
	if (!build_edge[YP])
	{
		var block = builder_get_block(build_pos[X], build_pos[Y] + 1, build_pos[Z]);
		if (block != null && block != block_current)
			south = "true"
	}
	
	if (!build_edge[YN])
	{
		var block = builder_get_block(build_pos[X], build_pos[Y] - 1, build_pos[Z]);
		if (block != null && block != block_current)
			north = "true"
	}
	
	if (!build_edge[ZP])
	{
		var block = builder_get_block(build_pos[X], build_pos[Y], build_pos[Z] + 1);
		if (block != null && block != block_current)
			up = "true"
	}
	
	block_state_id_current = block_get_state_id(block_current, [ "variant", variant, "east", east, "west", west, "south", south, "north", north, "up", up ])
	
	return 0
}
