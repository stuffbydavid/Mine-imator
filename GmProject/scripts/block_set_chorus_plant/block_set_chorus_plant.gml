/// @desc Connects to other chorus plants, chorus flowers and end stone below.

function block_set_chorus_plant()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0
	
	if (!builder_scenery && build_size_total = 1)
		return 0
	
	var east, west, south, north, up, down;
	east = "false"
	west = "false"
	south = "false"
	north = "false"
	up = "false"
	down = "false"
	
	if (!build_edge[XP])
	{
		var block = builder_get_block(build_pos[X] + 1, build_pos[Y], build_pos[Z]);
		if (block != null && (block = block_current || block.type = "chorus_plant_connect"))
			east = "true"
	}
	
	if (!build_edge[XN])
	{
		var block = builder_get_block(build_pos[X] - 1, build_pos[Y], build_pos[Z]);
		if (block != null && (block = block_current || block.type = "chorus_plant_connect"))
			west = "true"
	}
	
	if (!build_edge[YP])
	{
		var block = builder_get_block(build_pos[X], build_pos[Y] + 1, build_pos[Z]);
		if (block != null && (block = block_current || block.type = "chorus_plant_connect"))
			south = "true"
	}
	
	if (!build_edge[YN])
	{
		var block = builder_get_block(build_pos[X], build_pos[Y] - 1, build_pos[Z]);
		if (block != null && (block = block_current || block.type = "chorus_plant_connect"))
			north = "true"
	}
	
	if (!build_edge[ZP])
	{
		var block = builder_get_block(build_pos[X], build_pos[Y], build_pos[Z] + 1);
		if (block != null && (block = block_current || block.type = "chorus_plant_connect"))
			up = "true"
	}
	
	if (!build_edge[ZN])
	{
		var block = builder_get_block(build_pos[X], build_pos[Y], build_pos[Z] - 1);
		if (block != null && (block = block_current || block.type = "chorus_plant_connect" || block.name = "end_stone"))
			down = "true"
	}
	
	block_state_id_current = block_get_state_id(block_current, [ "east", east, "west", west, "south", south, "north", north, "up", up, "down", down ])
	
	return 0
}
