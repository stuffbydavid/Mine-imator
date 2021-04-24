/// block_set_tripwire()

function block_set_tripwire()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0
	
	var east, west, south, north;
	east = "false"
	west = "false"
	south = "false"
	north = "false"
	
	// X+
	if (!build_edge_xp)
	{
		var block = builder_get(block_obj, build_pos_x + 1, build_pos_y, build_pos_z);
		if (block != null && (block.name = "tripwire" || block.name = "tripwire_hook"))
			east = "true"
	}
	
	// X-
	if (!build_edge_xn)
	{
		var block = builder_get(block_obj, build_pos_x - 1, build_pos_y, build_pos_z);
		if (block != null && (block.name = "tripwire" || block.name = "tripwire_hook"))
			west = "true"
	}
	
	// Y+
	if (!build_edge_yp)
	{
		var block = builder_get(block_obj, build_pos_x, build_pos_y + 1, build_pos_z);
		if (block != null && (block.name = "tripwire" || block.name = "tripwire_hook"))
			south = "true"
	}
	
	// Y-
	if (!build_edge_yn)
	{
		var block = builder_get(block_obj, build_pos_x, build_pos_y - 1, build_pos_z);
		if (block != null && (block.name = "tripwire" || block.name = "tripwire_hook"))
			north = "true"
	}
	
	block_state_id_current = block_get_state_id(block_current, array("east", east, "west", west, "south", south, "north", north))
	
	return 0
}
