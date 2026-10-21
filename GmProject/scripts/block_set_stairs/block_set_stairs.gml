/// @desc Defines logic for connecting adjacent stairs.

function block_set_stairs()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0
	
	var shape, half, facing;
	shape = "straight"
	half = block_get_state_id_value(block_current, block_state_id_current, "half")
	facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
	
	// X+
	if (!build_edge[XP] && (facing = "east" || facing = "west"))
	{
		var block = builder_get_block(build_pos[X] + 1, build_pos[Y], build_pos[Z]);
		if (block != null && block.type = "stairs")
		{
			var stateid = builder_get_state_id(build_pos[X] + 1, build_pos[Y], build_pos[Z]);
			if (block_get_state_id_value(block, stateid, "half") = half) // Same half
			{
				var otherfacing = block_get_state_id_value(block, stateid, "facing");
				if (facing = "east")
				{
					if (otherfacing = "south")
						shape = "outer_right"
					else if (otherfacing = "north")
						shape = "outer_left"
				}
				else // West
				{
					if (otherfacing = "south")
						shape = "inner_left"
					else if (otherfacing = "north")
						shape = "inner_right"
				}
			}
		}
	}
	
	// X-
	if (!build_edge[XN] && (facing = "east" || facing = "west"))
	{
		var block = builder_get_block(build_pos[X] - 1, build_pos[Y], build_pos[Z]);
		if (block != null && block.type = "stairs")
		{
			var stateid = builder_get_state_id(build_pos[X] - 1, build_pos[Y], build_pos[Z]);
			if (block_get_state_id_value(block, stateid, "half") = half) // Same half
			{
				var otherfacing = block_get_state_id_value(block, stateid, "facing");
				if (facing = "east")
				{
					if (otherfacing = "south")
						shape = "inner_right"
					else if (otherfacing = "north")
						shape = "inner_left"
				}
				else // West
				{
					if (otherfacing = "south")
						shape = "outer_left"
					else if (otherfacing = "north")
						shape = "outer_right"
				}
			}
		}
	}
	
	// Y+
	if (!build_edge[YP] && (facing = "south" || facing = "north"))
	{
		var block = builder_get_block(build_pos[X], build_pos[Y] + 1, build_pos[Z]);
		if (block != null && block.type = "stairs")
		{
			var stateid = builder_get_state_id(build_pos[X], build_pos[Y] + 1, build_pos[Z]);
			if (block_get_state_id_value(block, stateid, "half") = half) // Same half
			{
				var otherfacing = block_get_state_id_value(block, stateid, "facing");
				if (facing = "south")
				{
					if (otherfacing = "east")
						shape = "outer_left"
					else if (otherfacing = "west")
						shape = "outer_right"
				}
				else // North
				{
					if (otherfacing = "east")
						shape = "inner_right"
					else if (otherfacing = "west")
						shape = "inner_left"
				}
			}
		}
	}
	
	// Y-
	if (!build_edge[YN] && (facing = "south" || facing = "north"))
	{
		var block = builder_get_block(build_pos[X], build_pos[Y] - 1, build_pos[Z]);
		if (block != null && block.type = "stairs")
		{
			var stateid = builder_get_state_id(build_pos[X], build_pos[Y] - 1, build_pos[Z]);
			if (block_get_state_id_value(block, stateid, "half") = half) // Same half
			{
				var otherfacing = block_get_state_id_value(block, stateid, "facing");
				if (facing = "south")
				{
					if (otherfacing = "east")
						shape = "inner_left"
					else if (otherfacing = "west")
						shape = "inner_right"
				}
				else // North
				{
					if (otherfacing = "east")
						shape = "outer_right"
					else if (otherfacing = "west")
						shape = "outer_left"
				}
			}
		}
	}
	
	if (shape != "straight")
		block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "shape", shape)
	
	return 0
}
