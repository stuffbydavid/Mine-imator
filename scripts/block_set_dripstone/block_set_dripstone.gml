/// block_set_dripstone()

function block_set_dripstone()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0
	
	var thicknessprev, dir, size, sizeoffset, thickness;
	thicknessprev = block_get_state_id_value(block_current, block_state_id_current, "thickness")
	
	if (thicknessprev = "base")
		return 0
	
	dir = block_get_state_id_value(block_current, block_state_id_current, "vertical_direction")
	size = test(dir = "up", (build_size_z - 1) - build_pos_z, build_pos_z)
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
	else if (size >= (build_size_z - 1))
		thickness = "base"
	else
		thickness = "middle"
	
	block_state_id_current = block_get_state_id(block_current, array("vertical_direction", dir, "thickness", thickness))
	
	return 0
}