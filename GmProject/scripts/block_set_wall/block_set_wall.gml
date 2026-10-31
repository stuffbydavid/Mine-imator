function block_set_wall()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0

	if (!builder_scenery && build_size_xy = 1)
		return 0

	var connect, variant, states, tall;
	connect = array_create(4, 0)
	variant = block_get_state_id_value(block_current, block_state_id_current, "variant")
	states = [ "none", "low", "tall" ]
	tall = false

	// Check above
	if (!build_edge[ZP])
	{
		var pos, block;
		pos = vec3_add(build_pos, dir_get_vec3(ZP))
		block = builder_get_block(pos[X], pos[Y], pos[Z])
		if (block != null && (block.type = block_current.type || (block_face_min_depth[XP] = e_block_depth.DEPTH0 && block_face_full[XP])))
			tall = true
	}

	for (var i = 0; i < 2; i++)
	{
		for (var d = XP; d <= YN; d++)
		{
			if (build_edge[d] || (i > 0 && connect[d] = 0))
				continue

			var pos, block;
			pos = vec3_add(build_pos, dir_get_vec3(d))
			pos[Z] += i
			block = builder_get_block(pos[X], pos[Y], pos[Z])
			if (block = null)
				continue

			// Same walls and solid faces
			if (block.type = block_current.type || (block_face_min_depth[d] = e_block_depth.DEPTH0 && block_face_full[d]))
				connect[d]++
			
			// Fence gates
			else if (block.type = "fence_gate")
			{
				var facing = block_get_state_id_value(block, builder_get_state_id(pos[X], pos[Y], pos[Z]), "facing");
				if (facing != dir_names[d] && facing != dir_names[d ^ 1])
					connect[d]++
			}
		}

		if (!tall)
			break
	}

	// Determine if the middle piece should be rendered
	var up;
	if ((connect[XP] > 0 && connect[XN] > 0 && connect[YP] = 0 && connect[YN] = 0) ||
		(connect[XP] = 0 && connect[XN] = 0 && connect[YP] > 0 && connect[YN] > 0))
		up = "false"
	else
		up = "true"

	block_state_id_current = block_get_state_id(block_current, [
		"variant", variant, "east", states[connect[XP]], "west", states[connect[XN]],
		"south", states[connect[YP]], "north", states[connect[YN]], "up", up
	])

	return 0
}
