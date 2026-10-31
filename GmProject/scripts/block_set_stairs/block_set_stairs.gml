/// @desc Defines logic for connecting adjacent stairs.

function block_set_stairs()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0

	var shape, half, facing, leftfacings, rightfacings, facingdir;
	shape = "straight"
	half = block_get_state_id_value(block_current, block_state_id_current, "half")
	facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
	leftfacings = [ "north", "south", "east", "west" ]
	rightfacings = [ "south", "north", "west", "east" ]
	facingdir = -1

	for (var d = XP; d <= YN; d++)
	{
		if (facing = dir_names[d])
		{
			facingdir = d
			break
		}
	}

	if (facingdir < 0)
		return 0

	// Check positive then negative neighbors so negative corners take priority
	var firstdir = XP;
	if (facingdir >= YP)
		firstdir = YP

	for (var d = firstdir; d < firstdir + 2; d++)
	{
		if (build_edge[d])
			continue

		var pos, block;
		pos = vec3_add(build_pos, dir_get_vec3(d))
		block = builder_get_block(pos[X], pos[Y], pos[Z])
		if (block = null || block.type != "stairs")
			continue

		var stateid = builder_get_state_id(pos[X], pos[Y], pos[Z]);
		if (block_get_state_id_value(block, stateid, "half") != half)
			continue

		var otherfacing, corner, turn;
		otherfacing = block_get_state_id_value(block, stateid, "facing")
		if (otherfacing = leftfacings[facingdir])
			turn = "left"
		else if (otherfacing = rightfacings[facingdir])
			turn = "right"
		else
			continue

		corner = "inner"
		if (d = facingdir)
			corner = "outer"

		shape = corner + "_" + turn
	}

	if (shape != "straight")
		block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "shape", shape)

	return 0
}
