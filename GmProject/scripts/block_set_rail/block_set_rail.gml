/// @desc Connects straight rails while preserving existing corners and slopes.

function block_set_rail()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0

	var shape = block_get_state_id_value(block_current, block_state_id_current, "shape");
	if (shape != "north_south" && shape != "east_west")
		return 0

	var connections, ascending;
	connections = []
	ascending = ""
	for (var d = XP; d <= YN; d++)
	{
		if (build_edge[d])
			continue

		var pos, block, found;
		found = false
		pos = vec3_add(build_pos, dir_get_vec3(d))
		block = builder_get_block(pos[X], pos[Y], pos[Z])
		
		if (block != null && block.type = "rail")
		{
			array_add(connections, d)
			found = true
		}
		else if (!build_edge[ZP])
		{
			var above = builder_get_block(pos[X], pos[Y], pos[Z] + 1);
			if (above != null && above.type = "rail")
			{
				array_add(connections, d)
				ascending = "ascending_" + dir_names[d]
				found = true
			}
		}
		if (!found && block = null && !build_edge[ZN])
		{
			block = builder_get_block(pos[X], pos[Y], pos[Z] - 1)
			if (block != null && block.type = "rail")
				array_add(connections, d)
		}
	}

	var count = array_length(connections);
	if (count = 1)
		shape = connections[0] <= XN ? "east_west" : "north_south"
	else if (count = 2)
	{
		var first, second;
		first = connections[0]
		second = connections[1]
		
		if ((first ^ 1) = second)
			shape = first <= XN ? "east_west" : "north_south"
		else
			shape = dir_names[second] + "_" + dir_names[first]
	}

	var states = block_current.states_map[?"shape"];
	if (ascending != "")
		shape = ascending
	
	if (ds_map_exists(states.value_map, shape))
		block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "shape", shape)

	return 0
}
