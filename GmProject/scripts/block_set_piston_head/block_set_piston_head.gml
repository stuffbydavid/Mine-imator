/// @desc Hides the head mesh when its base is rendered by a piston timeline.

function block_set_piston_head()
{
	if (!mc_builder.block_tl_add || block_tl_map = null)
		return 0

	var facing, dirs;
	facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
	dirs = dir_names

	for (var d = XP; d <= ZN; d++)
	{
		if (dirs[d] != facing)
			continue

		if (build_edge[d ^ 1])
			return 0

		var pos, base, state;
		pos = vec3_sub(build_pos, dir_get_vec3(d))
		base = builder_get_block(pos[X], pos[Y], pos[Z])
		if (base = null || base.type != "piston" || !base.timeline)
			return 0

		if (mc_builder.block_tl_types != null && !array_contains(mc_builder.block_tl_types, base.tl_type))
			return 0

		if (build_edit)
		{
			var index = (pos[Z] * build_size[Y] + pos[Y]) * build_size[X] + pos[X];
			if (block_tl_map[?index] != base.block_id)
				return 0
		}

		state = builder_get_state_id(pos[X], pos[Y], pos[Z])
		if (block_get_state_id_value(base, state, "extended") != "true" ||
			block_get_state_id_value(base, state, "facing") != facing)
			return 0

		var headtype = (base.name = "sticky_piston" ? "sticky" : "normal");
		if (block_get_state_id_value(block_current, block_state_id_current, "type") = headtype)
			return null

		return 0
	}

	return 0
}
