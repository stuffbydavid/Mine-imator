/// @desc Connect to other redstone wires, or powered blocks facing the opposite direction.

function block_set_redstone_wire()
{
	var pow, powval;
	pow = block_get_state_id_value(block_current, block_state_id_current, "power")
	powval = clamp(string_get_real(pow), 0, 15)

	block_color_index = e_color_palette.REDSTONE + powval + 1
	block_vertex_emissive = powval / 15

	if (builder_scenery && !builder_scenery_legacy)
		return 0

	if (!builder_scenery && build_size_total = 1)
		return 0

	var connect = array_create(4, "none");

	for (var d = XP; d <= YN; d++)
	{
		if (build_edge[d])
			continue

		var pos, block;
		pos = vec3_add(build_pos, dir_get_vec3(d))
		block = builder_get_block(pos[X], pos[Y], pos[Z])

		// Check side
		if (block != null)
		{
			if (block = block_current || block.type = "redstone_connect")
				connect[d] = "side"
			else if (block.type = "redstone_repeater" || block.type = "redstone_comparator")
			{
				var facing = block_get_state_id_value(block, builder_get_state_id(pos[X], pos[Y], pos[Z]), "facing");
				if (facing = dir_names[d] || facing = dir_names[d ^ 1])
					connect[d] = "side"
			}
		}

		// Check up
		if (connect[d] = "none" && !build_edge[ZP] && !(block_face_min_depth[ZP] = e_block_depth.DEPTH0 && block_face_full[ZP]))
		{
			block = builder_get_block(pos[X], pos[Y], pos[Z] + 1)
			if (block = block_current)
				connect[d] = "up"
		}

		// Check down
		if (connect[d] = "none" && !build_edge[ZN] && !(block_face_min_depth[d] = e_block_depth.DEPTH0 && block_face_full[d]))
		{
			block = builder_get_block(pos[X], pos[Y], pos[Z] - 1)
			if (block = block_current)
				connect[d] = "side"
		}
	}

	// Not connected, set to cross shape
	if (!array_contains(connect, "side") && !array_contains(connect, "up"))
		connect = array_create(4, "side")

	block_state_id_current = block_get_state_id(block_current, [
		"east", connect[XP], "west", connect[XN], "south", connect[YP], "north", connect[YN], "power", pow
	])

	return 0
}
