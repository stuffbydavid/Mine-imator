/// @desc Set locked state.

function block_set_redstone_repeater()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0

	if (block_get_state_id_value(block_current, block_state_id_current, "locked") = "true")
		return 0

	var facing, locked, sidefacings;
	facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
	locked = "false"
	sidefacings = [ "south", "north", "east", "west" ]

	for (var d = XP; d <= YN; d++)
	{
		if (build_edge[d] || (facing != sidefacings[d] && facing != sidefacings[d ^ 1]))
			continue

		var pos, block;
		pos = vec3_add(build_pos, dir_get_vec3(d))
		block = builder_get_block(pos[X], pos[Y], pos[Z])
		if (block = null || block.name != "powered_repeater")
			continue

		var stateid = builder_get_state_id(pos[X], pos[Y], pos[Z]);
		if (block_get_state_id_value(block, stateid, "facing") = dir_names[d])
		{
			locked = "true"
			break
		}
	}

	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "locked", locked)

	return 0
}
