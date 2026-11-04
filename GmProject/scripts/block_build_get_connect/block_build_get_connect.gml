/// @desc Expands a block state into its connected positions for double blocks.
/// @arg block
/// @arg stateid
/// @arg position

function block_build_get_connect(block, stateid, blockpos)
{
	// Resolve the door's derived hinge position and direction
	if (block.type = "door")
		stateid = block_get_door_state(block, stateid)

	// Check for valid build data
	var connect = [ [ blockpos, block.block_id, stateid ] ];
	if (block.build_map = null)
		return connect

	// double=up adds a vertical half, double=facing adds a horizontal bed half
	var double = value_get_string(block.build_map[?"double"], "");
	if (double = "up")
	{
		// double_age keeps younger growth stages confined to one cell
		var minage = value_get_real(block.build_map[?"double_age"], 0);
		if (minage > 0 && real(block_get_state_id_value(block, stateid, "age")) < minage)
			return connect

		// Big dripleaf resolves the lower leaf to a stem during mesh generation
		if (block.type = "big_dripleaf")
		{
			if (block_get_state_id_value(block, stateid, "type") = "big_dripleaf")
				array_add(connect, [ vec3_add(blockpos, vec3(0, 0, 1)), block.block_id, stateid ], false)

			return connect
		}
	}
	else if (double != "facing")
		return connect

	// Add the connected half after converting its offset to scenery coordinates
	var connected = block_get_connect(block, stateid);
	if (connected != null)
	{
		var offset = connected[0];
		offset = vec3(offset[Y], -offset[X], offset[Z])
		array_add(connect, [ vec3_add(blockpos, offset), block.block_id, connected[1] ], false)
	}

	return connect
}
