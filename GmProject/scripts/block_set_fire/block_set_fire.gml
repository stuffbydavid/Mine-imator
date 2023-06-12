/// block_set_fire()
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
	
	if (!build_edge_xp)
	{
		var block = builder_get_block(build_pos_x + 1, build_pos_y, build_pos_z);
		if (block != null && block != block_current)
			east = "true"
	}
	
	if (!build_edge_xn)
	{
		var block = builder_get_block(build_pos_x - 1, build_pos_y, build_pos_z);
		if (block != null && block != block_current)
			west = "true"
	}
	
	if (!build_edge_yp)
	{
		var block = builder_get_block(build_pos_x, build_pos_y + 1, build_pos_z);
		if (block != null && block != block_current)
			south = "true"
	}
	
	if (!build_edge_yn)
	{
		var block = builder_get_block(build_pos_x, build_pos_y - 1, build_pos_z);
		if (block != null && block != block_current)
			north = "true"
	}
	
	if (!build_edge_zp)
	{
		var block = builder_get_block(build_pos_x, build_pos_y, build_pos_z + 1);
		if (block != null && block != block_current)
			up = "true"
	}
	
	block_state_id_current = block_get_state_id(block_current, array("variant", variant, "east", east, "west", west, "south", south, "north", north, "up", up))
	
	return 0
}
