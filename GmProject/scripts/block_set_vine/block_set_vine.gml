/// @desc Connects to non-air blocks above.

function block_set_vine()
{
	if (!builder_scenery_legacy)
		return 0
	
	var up = "false";
	
	if (!build_edge[ZP])
	{
		var block = builder_get_block(build_pos[X], build_pos[Y], build_pos[Z] + 1);
		if (block != null && block != block_current)
			up = "true"
	}
	
	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "up", up)
	
	return 0
}
