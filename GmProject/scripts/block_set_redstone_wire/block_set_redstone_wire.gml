/// @desc Connect to other redstone wires, or powered blocks facing the opposite direction.

function block_set_redstone_wire()
{
	var pow, powval;
	pow = block_get_state_id_value(block_current, block_state_id_current, "power")
	powval = clamp(string_get_real(pow), 0, 15)

	block_color_index = e_color_palette.REDSTONE + powval + 1
	block_vertex_emissive = powval / 15
	
	if (builder_scenery && !builder_scenery_legacy)
		return 0
	
	if (!builder_scenery && build_size_total = 1)
		return 0
	
	var east, west, south, north;
	east = "none"
	west = "none"
	south = "none"
	north = "none"
	
	// X+
	if (!build_edge[XP])
	{
		var block = builder_get_block(build_pos[X] + 1, build_pos[Y], build_pos[Z]); // Check side
		if (block != null)
		{
			// Connect to other redstone wire
			if (block = block_current || block.type = "redstone_connect")
				east = "side"
			else if (block.type = "redstone_repeater" || block.type = "redstone_comparator")
			{
				var facing = block_get_state_id_value(block, builder_get_state_id(build_pos[X] + 1, build_pos[Y], build_pos[Z]), "facing");
				if (facing = "east" || facing = "west")
					east = "side"
			}
		}
		
		if (east = "none" && !build_edge[ZP] && !(block_face_min_depth[ZP] = e_block_depth.DEPTH0 && block_face_full[ZP])) // Check up
		{
			block = builder_get_block(build_pos[X] + 1, build_pos[Y], build_pos[Z] + 1)
			if (block = block_current)
				east = "up"
		}
		
		if (east = "none" && !build_edge[ZN] && !(block_face_min_depth[XP] = e_block_depth.DEPTH0 && block_face_full[XP])) // Check down
		{
			block = builder_get_block(build_pos[X] + 1, build_pos[Y], build_pos[Z] - 1)
			if (block = block_current)
				east = "side"
		}
	}
	
	// X-
	if (!build_edge[XN])
	{
		var block = builder_get_block(build_pos[X] - 1, build_pos[Y], build_pos[Z]); // Check side
		if (block != null)
		{
			// Connect to other redstone wire
			if (block = block_current || block.type = "redstone_connect")
				west = "side"
			else if (block.type = "redstone_repeater" || block.type = "redstone_comparator")
			{
				var facing = block_get_state_id_value(block, builder_get_state_id(build_pos[X] - 1, build_pos[Y], build_pos[Z]), "facing");
				if (facing = "east" || facing = "west")
					west = "side"
			}
		}
		
		if (west = "none" && !build_edge[ZP] && !(block_face_min_depth[ZP] = e_block_depth.DEPTH0 && block_face_full[ZP])) // Check up
		{
			block = builder_get_block(build_pos[X] - 1, build_pos[Y], build_pos[Z] + 1)
			if (block = block_current)
				west = "up"
		}
		
		if (west = "none" && !build_edge[ZN] && !(block_face_min_depth[XN] = e_block_depth.DEPTH0 && block_face_full[XN])) // Check down
		{
			block = builder_get_block(build_pos[X] - 1, build_pos[Y], build_pos[Z] - 1)
			if (block = block_current)
				west = "side"
		}
	}
	
	// Y+
	if (!build_edge[YP])
	{
		var block = builder_get_block(build_pos[X], build_pos[Y] + 1, build_pos[Z]); // Check side
		if (block != null)
		{
			// Connect to other redstone wire
			if (block = block_current || block.type = "redstone_connect")
				south = "side"
			else if (block.type = "redstone_repeater" || block.type = "redstone_comparator")
			{
				var facing = block_get_state_id_value(block, builder_get_state_id(build_pos[X], build_pos[Y] + 1, build_pos[Z]), "facing");
				if (facing = "south" || facing = "north")
					south = "side"
			}
		}
		
		if (south = "none" && !build_edge[ZP] && !(block_face_min_depth[ZP] = e_block_depth.DEPTH0 && block_face_full[ZP])) // Check up
		{
			block = builder_get_block(build_pos[X], build_pos[Y] + 1, build_pos[Z] + 1)
			if (block = block_current)
				south = "up"
		}
		
		if (south = "none" && !build_edge[ZN] && !(block_face_min_depth[YP] = e_block_depth.DEPTH0 && block_face_full[YP])) // Check down
		{ 
			block = builder_get_block(build_pos[X], build_pos[Y] + 1, build_pos[Z] - 1)
			if (block = block_current)
				south = "side"
		}
	}
	
	// Y-
	if (!build_edge[YN])
	{
		var block = builder_get_block(build_pos[X], build_pos[Y] - 1, build_pos[Z]); // Check side
		if (block != null)
		{
			// Connect to other redstone wire
			if (block = block_current || block.type = "redstone_connect")
				north = "side"
			else if (block.type = "redstone_repeater" || block.type = "redstone_comparator")
			{
				var facing = block_get_state_id_value(block, builder_get_state_id(build_pos[X], build_pos[Y] - 1, build_pos[Z]), "facing");
				if (facing = "south" || facing = "north")
					north = "side"
			}
		}
		
		if (north = "none" && !build_edge[ZP] && !(block_face_min_depth[ZP] = e_block_depth.DEPTH0 && block_face_full[ZP])) // Check up
		{
			block = builder_get_block(build_pos[X], build_pos[Y] - 1, build_pos[Z] + 1)
			if (block = block_current)
				north = "up"
		}
		
		if (north = "none" && !build_edge[ZN] && !(block_face_min_depth[YN] = e_block_depth.DEPTH0 && block_face_full[YN])) // Check down
		{
			block = builder_get_block(build_pos[X], build_pos[Y] - 1, build_pos[Z] - 1)
			if (block = block_current)
				north = "side"
		}
	}
	
	// Not connected, set to cross shape
	if (east = "none" && west = "none" && south = "none" && north = "none")
	{
		east = "side"
		west = "side"
		south = "side"
		north = "side"
	}
	
	block_state_id_current = block_get_state_id(block_current, [ "east", east, "west", west, "south", south, "north", north, "power", pow ])
	
	return 0
}
