/// @desc Connects to other fences with the same material, fence gates and solid adjacent faces.

function block_set_fence()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0
	
	if (!builder_scenery && build_size[X] = 1 && build_size[Y] = 1)
		return 0
	
	var east, west, south, north, variant;
	east = "false"
	west = "false"
	south = "false"
	north = "false"
	variant = block_get_state_id_value(block_current, block_state_id_current, "variant")
	
	// X+
	if (!build_edge[XP])
	{
		var block = builder_get_block(build_pos[X] + 1, build_pos[Y], build_pos[Z]);
		if (block != null)
		{
			if (block.type = block_current.type || (block_face_min_depth[XP] = e_block_depth.DEPTH0 && block_face_full[XP])) // Same fences
				east = "true"
			else if (block.type = "fence_gate") // Fence gates
			{
				var facing = block_get_state_id_value(block, builder_get_state_id(build_pos[X] + 1, build_pos[Y], build_pos[Z]), "facing");
				if (facing != "east" && facing != "west")
					east = "true"
			}
		}
	}
	
	// X-
	if (!build_edge[XN])
	{
		var block = builder_get_block(build_pos[X] - 1, build_pos[Y], build_pos[Z]);
		if (block != null)
		{
			if (block.type = block_current.type || (block_face_min_depth[XN] = e_block_depth.DEPTH0 && block_face_full[XN])) // Same fences
				west = "true"
			else if (block.type = "fence_gate") // Fence gates
			{
				var facing = block_get_state_id_value(block, builder_get_state_id(build_pos[X] - 1, build_pos[Y], build_pos[Z]), "facing");
				if (facing != "east" && facing != "west")
					west = "true"
			}
		}
	}
	
	// Y+
	if (!build_edge[YP])
	{
		var block = builder_get_block(build_pos[X], build_pos[Y] + 1, build_pos[Z]);
		if (block != null)
		{
			if (block.type = block_current.type || (block_face_min_depth[YP] = e_block_depth.DEPTH0 && block_face_full[YP])) // Same fences
				south = "true"
			else if (block.type = "fence_gate") // Fence gates
			{
				var facing = block_get_state_id_value(block, builder_get_state_id(build_pos[X], build_pos[Y] + 1, build_pos[Z]), "facing");
				if (facing != "south" && facing != "north")
					south = "true"
			}
		}
	}
	
	// Y-
	if (!build_edge[YN])
	{
		var block = builder_get_block(build_pos[X], build_pos[Y] - 1, build_pos[Z]);
		if (block != null)
		{
			if (block.type = block_current.type || (block_face_min_depth[YN] = e_block_depth.DEPTH0 && block_face_full[YN])) // Same fences
				north = "true"
			else if (block.type = "fence_gate") // Fence gates
			{
				var facing = block_get_state_id_value(block, builder_get_state_id(build_pos[X], build_pos[Y] - 1, build_pos[Z]), "facing");
				if (facing != "south" && facing != "north")
					north = "true"
			}
		}
	}
	
	block_state_id_current = block_get_state_id(block_current, [ "variant", variant, "east", east, "west", west, "south", south, "north", north ])
	
	return 0
}
