function block_set_tripwire()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0

	if (!builder_scenery && build_size_xy = 1)
		return 0

	var connect = array_create(4, "false");

	for (var d = XP; d <= YN; d++)
	{
		if (build_edge[d])
			continue

		var pos, block;
		pos = vec3_add(build_pos, dir_get_vec3(d))
		block = builder_get_block(pos[X], pos[Y], pos[Z])

		if (block != null && (block.name = "tripwire" || block.name = "tripwire_hook"))
			connect[d] = "true"
	}

	block_state_id_current = block_get_state_id(block_current, [
		"east", connect[XP], "west", connect[XN], "south", connect[YP], "north", connect[YN]
	])

	return 0
}
