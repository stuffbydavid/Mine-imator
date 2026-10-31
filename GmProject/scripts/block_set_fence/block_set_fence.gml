/// @desc Connects to other fences with the same material, fence gates and solid adjacent faces.

function block_set_fence()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0

	if (!builder_scenery && build_size_xy = 1)
		return 0

	var connect, variant;
	connect = array_create(4, "false")
	variant = block_get_state_id_value(block_current, block_state_id_current, "variant")

	for (var d = XP; d <= YN; d++)
	{
		if (build_edge[d])
			continue

		var pos, block;
		pos = vec3_add(build_pos, dir_get_vec3(d))
		block = builder_get_block(pos[X], pos[Y], pos[Z])
		if (block = null)
			continue

		// Same fences and solid faces
		if (block.type = block_current.type || (block_face_min_depth[d] = e_block_depth.DEPTH0 && block_face_full[d]))
			connect[d] = "true"
		
		// Fence gates
		else if (block.type = "fence_gate")
		{
			var facing = block_get_state_id_value(block, builder_get_state_id(pos[X], pos[Y], pos[Z]), "facing");
			if (facing != dir_names[d] && facing != dir_names[d ^ 1])
				connect[d] = "true"
		}
	}

	block_state_id_current = block_get_state_id(block_current, [
		"variant", variant, "east", connect[XP], "west", connect[XN], "south", connect[YP], "north", connect[YN]
	])

	return 0
}
