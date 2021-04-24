/// block_set_redstone_repeater()
/// @desc Set locked state.

function block_set_redstone_repeater()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0
	
	if (block_get_state_id_value(block_current, block_state_id_current, "locked") = "true")
		return 0
	
	var facing, locked;
	facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
	locked = "false"
	
	if (!build_edge_xp && (facing = "south" || facing = "north"))
	{
		var block = builder_get(block_obj, build_pos_x + 1, build_pos_y, build_pos_z);
		if (block != null && block.name = "powered_repeater")
		{
			var stateid = builder_get(block_state_id, build_pos_x + 1, build_pos_y, build_pos_z);
			if (block_get_state_id_value(block, stateid, "facing") = "east")
				locked = "true"
		}
	}
	
	if (locked = "false" && !build_edge_xn && (facing = "south" || facing = "north"))
	{
		var block = builder_get(block_obj, build_pos_x - 1, build_pos_y, build_pos_z);
		if (block != null && block.name = "powered_repeater")
		{
			var stateid = builder_get(block_state_id, build_pos_x - 1, build_pos_y, build_pos_z);
			if (block_get_state_id_value(block, stateid, "facing") = "west")
				locked = "true"
		}
	}
	
	if (locked = "false" && !build_edge_yp && (facing = "east" || facing = "west"))
	{
		var block = builder_get(block_obj, build_pos_x, build_pos_y + 1, build_pos_z);
		if (block != null && block.name = "powered_repeater")
		{
			var stateid = builder_get(block_state_id, build_pos_x, build_pos_y + 1, build_pos_z);
			if (block_get_state_id_value(block, stateid, "facing") = "south")
				locked = "true"
		}
	}
	
	if (locked = "false" && !build_edge_yn && (facing = "east" || facing = "west"))
	{
		var block = builder_get(block_obj, build_pos_x, build_pos_y - 1, build_pos_z);
		if (block != null && block.name = "powered_repeater")
		{
			var stateid = builder_get(block_state_id, build_pos_x, build_pos_y - 1, build_pos_z);
			if (block_get_state_id_value(block, stateid, "facing") = "north")
				locked = "true"
		}
	}
	
	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "locked", locked)
	
	return 0
}
