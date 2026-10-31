/// @desc Connects to other chorus plants, chorus flowers and end stone below.

function block_set_chorus_plant()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0

	if (!builder_scenery && build_size_total = 1)
		return 0

	var connect = array_create(block_faces, "false");

	for (var d = XP; d <= ZN; d++)
	{
		if (build_edge[d])
			continue

		var pos, block;
		pos = vec3_add(build_pos, dir_get_vec3(d))
		block = builder_get_block(pos[X], pos[Y], pos[Z])

		if (block != null && (block = block_current || block.type = "chorus_plant_connect" || (d = ZN && block.name = "end_stone")))
			connect[d] = "true"
	}

	block_state_id_current = block_get_state_id(block_current, [
		"east", connect[XP], "west", connect[XN], "south", connect[YP], "north", connect[YN],
		"up", connect[ZP], "down", connect[ZN]
	])

	return 0
}
