/// @desc For double blocks, returns the offset and state of the connected block, or null.
/// @arg block
/// @arg stateid

function block_get_connect(block, stateid)
{
	if (!block.has_connect)
		return null

	// The first value connects along the offset, the second in reverse
	var connections = [
		[ "half", "lower", "upper" ],
		[ "part", "foot", "head" ],
		[ "type", "right", "left" ]
	];

	for (var i = 0; i < array_length(connections); i++)
	{
		var connection, part, offset, opposite;
		connection = connections[i]
		part = block_get_state_id_value(block, stateid, connection[0])
		if (part != connection[1] && part != connection[2])
			continue

		// Tall blocks connect vertically, beds and chests follow their facing
		offset = vec3(0, 0, 1)
		if (connection[0] != "half")
		{
			var facing, dir;
			facing = block_get_state_id_value(block, stateid, "facing")
			dir = -1
			for (var d = XP; d <= YN; d++)
				if (dir_names[d] = facing)
					dir = d

			if (dir = -1)
				return null

			offset = dir_get_vec3(dir)
			if (connection[0] = "type")
				offset = vec3(offset[Y], -offset[X], 0)
		}

		// Flip both the direction and state for the opposite half
		opposite = connection[2]
		if (part = connection[2])
		{
			offset = vec3_mul(offset, -1)
			opposite = connection[1]
		}

		// Return the offset and connected state ID
		return [ offset, block_set_state_id_value(block, stateid, connection[0], opposite) ]
	}

	return null
}
