/// @desc Locates non-air blocks.

function block_set_fire()
{
	if (!builder_scenery_legacy)
		return 0

	var connect, variant;
	connect = array_create(5, "false")
	variant = block_get_state_id_value(block_current, block_state_id_current, "variant")

	for (var d = XP; d <= ZP; d++)
	{
		if (build_edge[d])
			continue

		var pos, block;
		pos = vec3_add(build_pos, dir_get_vec3(d))
		block = builder_get_block(pos[X], pos[Y], pos[Z])

		if (block != null && block != block_current)
			connect[d] = "true"
	}

	block_state_id_current = block_get_state_id(block_current, [
		"variant", variant, "east", connect[XP], "west", connect[XN], "south", connect[YP], "north", connect[YN], "up", connect[ZP]
	])

	return 0
}
