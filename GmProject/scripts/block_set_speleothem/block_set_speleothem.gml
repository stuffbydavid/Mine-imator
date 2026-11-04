/// @desc Returns the automatic spike model while preserving the selected thickness.

function block_set_speleothem()
{
	if (!build_edit && builder_scenery && !builder_scenery_legacy)
		return 0

	// Preserve thickness values explicitly selected by the user
	if (block_get_state_id_value(block_current, block_state_id_current, "thickness") != "tip")
		return 0

	var minz, maxz;
	minz = 0
	maxz = build_size[Z]
	if (build_edit)
	{
		minz = build_min_pos[Z]
		maxz = build_max_pos[Z]
	}

	// Count up to two consecutive spikes toward the tip
	var dir, step, count;
	dir = block_get_state_id_value(block_current, block_state_id_current, "vertical_direction")
	step = 1
	if (dir = "down")
		step = -1

	count = 0
	for (var distance = 1; distance <= 2; distance++)
	{
		var zz = build_pos[Z] + step * distance;
		if (zz < minz || zz >= maxz || builder_get_block(build_pos[X], build_pos[Y], zz) != block_current)
			break

		var stateid = builder_get_state_id(build_pos[X], build_pos[Y], zz);
		if (block_get_state_id_value(block_current, stateid, "vertical_direction") != dir)
			break

		count++
	}

	// One or more spikes beyond this block make it a middle section
	var thickness = "tip";
	if (count > 0)
		thickness = "middle"

	// A non-spike support makes the start of a stack of at least three the base
	if (count = 2)
	{
		var zz = build_pos[Z] - step;
		if (zz >= minz && zz < maxz)
		{
			var support = builder_get_block(build_pos[X], build_pos[Y], zz);
			if (support != null && support != block_current)
				thickness = "base"
		}
	}

	if (thickness = "tip")
		return 0

	// Keep tip in the block data so subsequent edits can resolve the shape again
	var modelstate = block_set_state_id_value(block_current, block_state_id_current, "thickness", thickness);
	return block_get_render_model(
		block_current.state_id_model_obj[modelstate],
		block_current.state_id_emissive[modelstate],
		block_current.state_id_random_offset[modelstate],
		block_current.state_id_random_offset_xy[modelstate]
	)
}
