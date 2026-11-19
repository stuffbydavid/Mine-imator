/// @desc Connects to fences and cobblestone walls in the same direction.

function block_set_fence_gate()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0
	
	var block, facing, inwall;
	facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
	inwall = "false"
	
	if (facing = "east" || facing = "west")
	{
		// Check south for wall
		if (!build_edge[YP])
		{
			block = builder_get_block(build_pos[X], build_pos[Y] + 1, build_pos[Z])
			if (block != null && block.type = "wall")
				inwall = "true"
		}
		
		// Check north for wall
		if (inwall = "false" && !build_edge[YN])
		{
			block = builder_get_block(build_pos[X], build_pos[Y] - 1, build_pos[Z])
			if (block != null && block.type = "wall")
				inwall = "true"
		}
	}
	else if (facing = "south" || facing = "north")
	{
		// Check east for wall
		if (!build_edge[XP])
		{
			block = builder_get_block(build_pos[X] + 1, build_pos[Y], build_pos[Z])
			if (block != null && block.type = "wall")
				inwall = "true"
		}
		
		// Check west for wall
		if (inwall = "false" && !build_edge[XN])
		{
			block = builder_get_block(build_pos[X] - 1, build_pos[Y], build_pos[Z])
			if (block != null && block.type = "wall")
				inwall = "true"
		}
	}
	
	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "in_wall", inwall)
	
	return 0
}
