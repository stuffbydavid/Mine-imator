function block_set_icicle()
{
	// TODO: fix attached state for build tool
	
	if (!build_edit && builder_scenery && !builder_scenery_legacy)
		return 0
	
	if (block_get_state_id_value(block_current, block_state_id_current, "attached") = "true")
	{
		// Remove "attached" from all blocks
		block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "attached", "false")
		
		var dir = block_get_state_id_value(block_current, block_state_id_current, "vertical_direction");
		
		// Apply "attached" to all bottom/top blocks
		if (builder_get_block(build_pos[X], build_pos[Y], build_pos[Z]) = block_current && 
			((dir = "up" && build_edge[ZN]) || (dir = "down" && build_edge[ZP]))
		)
			block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "attached", "true")
	}
	
	return block_set_speleothem()
}
