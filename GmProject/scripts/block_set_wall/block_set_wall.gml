/// block_set_wall()

function block_set_wall()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0
	
	var east, west, south, north, variant, states, tall, i;
	east = 0
	west = 0
	south = 0
	north = 0
	variant = block_get_state_id_value(block_current, block_state_id_current, "variant")
	states = array("none", "low", "tall")
	tall = false
	i = 0
	
	// Z+
	if (!build_edge_zp)
	{
		var block = builder_get_block(build_pos_x, build_pos_y, build_pos_z + 1);
		if (block != null)
		{
			if (block.type = block_current.type || (block_face_min_depth_xp = e_block_depth.DEPTH0 && block_face_full_xp)) // Same walls
				tall = true
		}
	}
	
	repeat (2)
	{
		// X+
		if (!build_edge_xp && (i = 0 || (i = 1 && east)))
		{
			var block = builder_get_block(build_pos_x + 1, build_pos_y, build_pos_z + i);
			if (block != null)
			{
				if (block.type = block_current.type || (block_face_min_depth_xp = e_block_depth.DEPTH0 && block_face_full_xp)) // Same walls
					east++
				else if (block.type = "fence_gate") // Fence gates
				{
					var facing = block_get_state_id_value(block, builder_get_state_id(build_pos_x + 1, build_pos_y, build_pos_z + i), "facing")
					if (facing != "east" && facing != "west")
						east++
				}
			}
		}
		
		// X-
		if (!build_edge_xn && (i = 0 || (i = 1 && west)))
		{
			var block = builder_get_block(build_pos_x - 1, build_pos_y, build_pos_z + i);
			if (block != null)
			{
				if (block.type = block_current.type || (block_face_min_depth_xn = e_block_depth.DEPTH0 && block_face_full_xn)) // Same walls
					west++
				else if (block.type = "fence_gate") // Fence gates
				{
					var facing = block_get_state_id_value(block, builder_get_state_id(build_pos_x - 1, build_pos_y, build_pos_z + i), "facing")
					if (facing != "east" && facing != "west")
						west++
				}
			}
		}
		
		// Y+
		if (!build_edge_yp && (i = 0 || (i = 1 && south)))
		{
			var block = builder_get_block(build_pos_x, build_pos_y + 1, build_pos_z + i);
			if (block != null)
			{
				if (block.type = block_current.type || (block_face_min_depth_yp = e_block_depth.DEPTH0 && block_face_full_yp)) // Same walls
					south++
				else if (block.type = "fence_gate") // Fence gates
				{
					var facing = block_get_state_id_value(block, builder_get_state_id(build_pos_x, build_pos_y + 1, build_pos_z + i), "facing")
					if (facing != "south" && facing != "north")
						south++
				}
			}
		}
		
		// Y-
		if (!build_edge_yn && (i = 0 || (i = 1 && north)))
		{
			var block = builder_get_block(build_pos_x, build_pos_y - 1, build_pos_z + i);
			if (block != null)
			{
				if (block.type = block_current.type || (block_face_min_depth_yn = e_block_depth.DEPTH0 && block_face_full_yn)) // Same fences/walls
					north++
				else if (block.type = "fence_gate") // Fence gates
				{
					var facing = block_get_state_id_value(block, builder_get_state_id(build_pos_x, build_pos_y - 1, build_pos_z + i), "facing")
					if (facing != "south" && facing != "north")
						north++
				}
			}
		}
		
		if (!tall)
			break
		else
			i++
	}
	
	// Determine if the middle piece should be rendered
	var up;
	if ((east > 0 && west > 0 && south = 0 && north = 0) ||
		(east = 0 && west = 0 && south > 0 && north > 0))
		up = "false"
	else
		up = "true"
	
	block_state_id_current = block_get_state_id(block_current, array("variant", variant, "east", states[east], "west", states[west], "south", states[south], "north", states[north], "up", up))
	
	return 0
}
