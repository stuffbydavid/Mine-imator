/// @desc Check for a snow block above the current block.

function block_set_snowy()
{
	if (block_get_state_id_value(block_current, block_state_id_current, "snowy") = "true")
		return 0
	
	var snowy = "false";
	
	if (!build_edge[ZP])
	{
		var otherblock = builder_get_block(build_pos[X], build_pos[Y], build_pos[Z] + 1);
		if (otherblock != null && otherblock.type = "snow")
			snowy = "true"
	}
	
	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "snowy", snowy)
	
	return 0
}
