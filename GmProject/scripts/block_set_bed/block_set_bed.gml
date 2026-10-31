/// @desc Returns an array with the head and foot models.

function block_set_bed()
{
	var facing, part;
	facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
	part = block_get_state_id_value(block_current, block_state_id_current, "part")
	
	// Patch legacy orientation and half
	if ((builder_scenery || build_edit) && builder_scenery_legacy)
	{
		var offsets, directions, color, matches, corrected;
		offsets = [ [ 1, 0 ], [ -1, 0 ], [ 0, 1 ], [ 0, -1 ] ]
		directions = [ "west", "east", "north", "south" ]
		color = block_get_state_id_value(block_current, block_state_id_current, "color")
		matches = 0
		corrected = facing
		
		for (var d = XP; d <= YN; d++)
		{
			var xx, yy, state;
			if (build_edge[d])
				continue
			
			xx = build_pos[X] + offsets[d][X]
			yy = build_pos[Y] + offsets[d][Y]
			if (builder_get_block(xx, yy, build_pos[Z]) != block_current)
				continue
			
			state = builder_get_state_id(xx, yy, build_pos[Z])
			if (block_get_state_id_value(block_current, state, "part") = part || block_get_state_id_value(block_current, state, "color") != color)
				continue
			
			corrected = directions[d]
			if (part = "foot")
				corrected = directions[d ^ 1]
			
			matches++
			if (corrected = facing)
				break
		}
		
		if (matches = 1)
			facing = corrected
		
		block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "facing", facing)
	}
	
	// Offset from the head to the foot
	var offset = vec3(0);
	switch (facing)
	{
		case "north": offset[Y] = 1; break
		case "south": offset[Y] = -1; break
		case "east":  offset[X] = -1; break
		case "west":  offset[X] = 1; break
		default:	  return null
	}

	// Find connected block position
	if (build_get_connect)
	{
		if (part = "foot")
			offset = vec3_mul(offset, -1)
		else if (part != "head")
			return null

		var pos, state;
		pos = vec3_add(build_pos, offset)
		if (builder_get_block(pos[X], pos[Y], pos[Z]) != block_current)
			return null

		state = builder_get_state_id(pos[X], pos[Y], pos[Z])
		if (block_get_state_id_value(block_current, state, "part") != (part = "head" ? "foot" : "head") ||
			block_get_state_id_value(block_current, state, "color") != block_get_state_id_value(block_current, block_state_id_current, "color"))
			return null

		if (!builder_scenery_legacy && block_get_state_id_value(block_current, state, "facing") != facing)
			return null

		return pos
	}

	if (builder_scenery || build_edit)
	{
		// Cull each half against its own neighbors, without the standalone bed's offset
		var model = block_current.state_id_model_obj[block_state_id_current].model[0];
		model.offset[X] = 0
		model.offset[Y] = 0
		return 0
	}
	
	if (part = "foot")
		return null
	
	// Pick models
	var headmodel, footmodel;
	headmodel = block_current.state_id_model_obj[block_state_id_current].model[0]
	footmodel = block_current.state_id_model_obj[block_set_state_id_value(block_current, block_state_id_current, "part", "foot")].model[0]
	
	footmodel.offset[X] = offset[X] * block_size
	footmodel.offset[Y] = offset[Y] * block_size
	
	return [ headmodel.rendermodel_id, footmodel.rendermodel_id ]
}
