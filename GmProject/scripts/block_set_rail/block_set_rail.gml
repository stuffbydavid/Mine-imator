/// @desc Connects neighboring rails and updates regular rail corners and slopes.

function block_set_rail()
{
	if (builder_scenery && !builder_scenery_legacy)
		return 0

	var shape, updateslopes;
	shape = block_get_state_id_value(block_current, block_state_id_current, "shape")
	updateslopes = (build_edit && block_current.name = "rail")

	if (!updateslopes && shape != "north_south" && shape != "east_west")
		return 0

	// Return old slopes to their horizontal axis before checking current connections
	if (updateslopes && string_pos("ascending_", shape) = 1)
	{
		if (shape = "ascending_east" || shape = "ascending_west")
			shape = "east_west"
		else
			shape = "north_south"
	}

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

		// Prefer upper neighbors only when they have a free connection
		if ((!found || updateslopes) && !build_edge[ZP])
		{
			var above = builder_get_block(pos[X], pos[Y], pos[Z] + 1);
			if (above != null && above.type = "rail")
			{
				// Keep the upper rail's existing connections, excluding this lower rail
				var upperconnections = 0;
				if (updateslopes)
				{
					var uppershape = block_get_state_id_value(above, builder_get_state_id(pos[X], pos[Y], pos[Z] + 1), "shape");
					if (string_pos("ascending_", uppershape) = 1)
					{
						if (uppershape = "ascending_east" || uppershape = "ascending_west")
							uppershape = "east_west"
						else
							uppershape = "north_south"
					}

					for (var n = XP; n <= YN && upperconnections < 2; n++)
					{
						if (string_pos(dir_names[n], uppershape) = 0)
							continue

						var neighborpos, axis;
						neighborpos = vec3_add(pos, dir_get_vec3(n))
						axis = n div 2
						if (neighborpos[axis] < build_min_pos[axis] || neighborpos[axis] >= build_max_pos[axis])
							continue

						// Rail ends can connect at the same height or one block above or below
						for (var height = -1; height <= 1; height++)
						{
							neighborpos[Z] = pos[Z] + 1 + height
							if (neighborpos[Z] < build_min_pos[Z] || neighborpos[Z] >= build_max_pos[Z] || vec3_equals(neighborpos, build_pos))
								continue

							var neighbor = builder_get_block(neighborpos[X], neighborpos[Y], neighborpos[Z]);
							if (neighbor != null && neighbor.type = "rail")
							{
								upperconnections++
								break
							}
						}
					}
				}

				if (upperconnections < 2)
				{
					if (!found)
						array_add(connections, d)

					ascending = "ascending_" + dir_names[d]
					found = true
				}
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
