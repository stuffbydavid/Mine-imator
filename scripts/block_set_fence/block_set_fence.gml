/// block_set_fence()
/// @desc Connects to other fences with the same material, fence gates and solid adjacent faces.

if (builder_scenery && !builder_scenery_legacy)
	return 0

var east, west, south, north, variant;
east = "false"
west = "false"
south = "false"
north = "false"
variant = block_get_state_id_value(block_current, block_state_id_current, "variant")

// X+
if (!build_edge_xp)
{
	var block = builder_get(block_obj, build_pos_x + 1, build_pos_y, build_pos_z);
	if (block != null)
	{
		if (block.type = block_current.type || (block_face_min_depth_xp = e_block_depth.DEPTH0 && block_face_full_xp)) // Same fences
			east = "true"
		else if (block.type = "fence_gate") // Fence gates
		{
			var facing = block_get_state_id_value(block, builder_get(block_state_id, build_pos_x + 1, build_pos_y, build_pos_z), "facing")
			if (facing != "east" && facing != "west")
				east = "true"
		}
	}
}

// X-
if (!build_edge_xn)
{
	var block = builder_get(block_obj, build_pos_x - 1, build_pos_y, build_pos_z);
	if (block != null)
	{
		if (block.type = block_current.type || (block_face_min_depth_xn = e_block_depth.DEPTH0 && block_face_full_xn)) // Same fences
			west = "true"
		else if (block.type = "fence_gate") // Fence gates
		{
			var facing = block_get_state_id_value(block, builder_get(block_state_id, build_pos_x - 1, build_pos_y, build_pos_z), "facing")
			if (facing != "east" && facing != "west")
				west = "true"
		}
	}
}

// Y+
if (!build_edge_yp)
{
	var block = builder_get(block_obj, build_pos_x, build_pos_y + 1, build_pos_z);
	if (block != null)
	{
		if (block.type = block_current.type || (block_face_min_depth_yp = e_block_depth.DEPTH0 && block_face_full_yp)) // Same fences
			south = "true"
		else if (block.type = "fence_gate") // Fence gates
		{
			var facing = block_get_state_id_value(block, builder_get(block_state_id, build_pos_x, build_pos_y + 1, build_pos_z), "facing")
			if (facing != "south" && facing != "north")
				south = "true"
		}
	}
}

// Y-
if (!build_edge_yn)
{
	var block = builder_get(block_obj, build_pos_x, build_pos_y - 1, build_pos_z);
	if (block != null)
	{
		if (block.type = block_current.type || (block_face_min_depth_yn = e_block_depth.DEPTH0 && block_face_full_yn)) // Same fences
			north = "true"
		else if (block.type = "fence_gate") // Fence gates
		{
			var facing = block_get_state_id_value(block, builder_get(block_state_id, build_pos_x, build_pos_y - 1, build_pos_z), "facing")
			if (facing != "south" && facing != "north")
				north = "true"
		}
	}
}

block_state_id_current = block_get_state_id(block_current, array("variant", variant, "east", east, "west", west, "south", south, "north", north))

return 0