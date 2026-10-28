function block_set_speleothem()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0
	
	var minz, maxz;
	minz = 0
	maxz = build_size[Z]
	
	if (build_edit)
	{
		minz = build_min_pos[Z]
		maxz = build_max_pos[Z]
	}

	if (!builder_scenery && maxz - minz = 1)
		return 0
	
	var thicknessprev, dir, size, sizeoffset, thickness;
	thicknessprev = block_get_state_id_value(block_current, block_state_id_current, "thickness")
	
	if (thicknessprev = "base")
		return 0
	
	dir = block_get_state_id_value(block_current, block_state_id_current, "vertical_direction")
	size = (dir = "up" ? (maxz - 1) - build_pos[Z] : build_pos[Z] - minz)
	sizeoffset = size
	
	if (thicknessprev = "frustum")
		sizeoffset += 1
	else if (thicknessprev = "middle")
		sizeoffset += 2
	else if (thicknessprev = "base")
		sizeoffset += 3
	
	if (sizeoffset = 0)
		thickness = thicknessprev
	else if (sizeoffset = 1)
		thickness = "frustum"
	else if (size >= maxz - minz - 1)
		thickness = "base"
	else
		thickness = "middle"
	
	block_state_id_current = block_get_state_id(block_current, [ "vertical_direction", dir, "thickness", thickness ])
	
	return 0
}
