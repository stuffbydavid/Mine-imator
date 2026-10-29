/// @desc Connects to other bars and panes or solid faces.

function block_set_bars()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0
	
	if (!builder_scenery && build_size_xy = 1)
		return 0
	
	var east, west, south, north;
	east = "false"
	west = "false"
	south = "false"
	north = "false"
	
	// X+
	if (!build_edge[XP])
	{
		var block = builder_get_block(build_pos[X] + 1, build_pos[Y], build_pos[Z]);
		if ((block != null && (block.type = "bars" || block.type = "colored_bars")) ||
			(block_face_min_depth[XP] != e_block_depth.DEPTH1 && block_face_full[XP]))
			east = "true"
	}
	
	// X-
	if (!build_edge[XN])
	{
		var block = builder_get_block(build_pos[X] - 1, build_pos[Y], build_pos[Z]);
		if ((block != null && (block.type = "bars" || block.type = "colored_bars")) ||
			(block_face_min_depth[XN] != e_block_depth.DEPTH1 && block_face_full[XN]))
			west = "true"
	}
	
	// Y+
	if (!build_edge[YP])
	{
		var block = builder_get_block(build_pos[X], build_pos[Y] + 1, build_pos[Z]);
		if ((block != null && (block.type = "bars" || block.type = "colored_bars")) ||
			(block_face_min_depth[YP] != e_block_depth.DEPTH1 && block_face_full[YP]))
			south = "true"
	}
	
	// Y-
	if (!build_edge[YN])
	{
		var block = builder_get_block(build_pos[X], build_pos[Y] - 1, build_pos[Z]);
		if ((block != null && (block.type = "bars" || block.type = "colored_bars")) ||
			(block_face_min_depth[YN] != e_block_depth.DEPTH1 && block_face_full[YN]))
			north = "true"
	}
	
	block_state_id_current = block_get_state_id(block_current, [ "east", east, "west", west, "south", south, "north", north ])
	
	return 0
}
