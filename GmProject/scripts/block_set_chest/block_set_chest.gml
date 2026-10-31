/// @desc Finds double chests.

function block_set_chest()
{
	var type, double, staticmodel, facing;
	type = block_get_state_id_value(block_current, block_state_id_current, "type")
	facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
	double = "false"
	staticmodel = (build_get_connect || !mc_builder.block_tl_add || block_tl_map = null)

	if (build_edit && !staticmodel)
		staticmodel = (block_tl_map[?build_pos_index] != block_current.block_id)

	if (mc_builder.block_tl_types != null && !array_contains(mc_builder.block_tl_types, block_current.tl_type))
		staticmodel = true
	
	// Resolve source chests during both removal and regeneration
	var legacy = (builder_scenery && builder_scenery_legacy);
	if (build_edit && builder_scenery_legacy && block_tl_map != null)
		legacy = (block_tl_map[?build_pos_index] = block_current.block_id)

	if (legacy)
		type = "legacy"
	
	switch (type)
	{
		case "single":	break
		case "right":	double = "true"; break
		case "left":
		{
			if (!staticmodel)
				return null

			double = "true"
			break
		}
		
		case "legacy":
		{
			if (block_current.name = "ender_chest")
				break
				
			// Determine type from adjacent chest
			var connectblock, discardblock;
			connectblock = null
			discardblock = null
			
			// Patch legacy orientation
			if (legacy)
			{
				var directions, offsets, neighbors, pair, origin, paired, blocked, face;
				directions = [ "east", "west", "south", "north" ]
				offsets = [ [ 1, 0 ], [ -1, 0 ], [ 0, 1 ], [ 0, -1 ] ]
				neighbors = 0
				pair = null
				origin = vec3(build_pos[X], build_pos[Y], build_pos[Z])
				paired = origin
				blocked = [ false, false, false, false ]
				
				// Resolve both halves from the same chest, regardless of their stored facing
				for (var d = XP; d <= YN; d++)
				{
					if (!build_edge[d] && builder_get_block(build_pos[X] + offsets[d][X], build_pos[Y] + offsets[d][Y], build_pos[Z]) = block_current)
					{
						pair = d
						neighbors++
					}
				}
				
				if (neighbors = 1)
				{
					paired = vec3(origin[X] + offsets[pair][X], origin[Y] + offsets[pair][Y], origin[Z])
					if (pair = XN || pair = YN)
					{
						var swap = origin;
						origin = paired
						paired = swap
					}
					
					facing = block_get_state_id_value(block_current, builder_get_state_id(origin[X], origin[Y], origin[Z]), "facing")
					
					// A double chest must face perpendicular to its joining edge
					if (pair <= XN && (facing = "east" || facing = "west"))
						facing = "north"
					else if (pair >= YP && (facing = "north" || facing = "south"))
						facing = "east"
				}
				
				// Inspect the original block models before the builder has generated neighbor meshes
				for (var p = 0; p < (neighbors = 1 ? 2 : 1); p++)
				{
					var pos = (p = 0 ? origin : paired);
					for (var d = XP; d <= YN; d++)
					{
						var xx, yy, block, state, model;
						xx = pos[X] + offsets[d][X]
						yy = pos[Y] + offsets[d][Y]
						
						if (xx < 0 || yy < 0 || xx >= build_size[X] || yy >= build_size[Y])
							continue
						
						block = builder_get_block(xx, yy, pos[Z])
						if (block = null || block.state_id_model_obj = null)
							continue
						
						state = builder_get_state_id(xx, yy, pos[Z])
						model = block.state_id_model_obj[state]
						if (is_undefined(model) || model = null || is_array(model))
							continue
						
						if (model.model_amount = 0)
							continue
						
						model = model.model[0]
						if (model.face_full[d ^ 1] && model.face_min_depth[d ^ 1] = e_block_depth.DEPTH0)
							blocked[d] = true
					}
				}
				
				face = XP
				for (var d = XP; d <= YN; d++)
					if (directions[d] = facing)
						face = d
				
				if (blocked[face] && !blocked[face ^ 1])
					facing = directions[face ^ 1]
				
				block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "facing", facing)
			}
			
			switch (facing)
			{
				case "east":
				{
					if (!build_edge[YN])
						connectblock = builder_get_block(build_pos[X], build_pos[Y] - 1, build_pos[Z])
					
					if (!build_edge[YP])
						discardblock = builder_get_block(build_pos[X], build_pos[Y] + 1, build_pos[Z])
					
					break
				}
				
				case "west":
				{
					if (!build_edge[YP])
						connectblock = builder_get_block(build_pos[X], build_pos[Y] + 1, build_pos[Z])
					
					if (!build_edge[YN])
						discardblock = builder_get_block(build_pos[X], build_pos[Y] - 1, build_pos[Z])
					
					break
				}
				
				case "south":
				{
					if (!build_edge[XP])
						connectblock = builder_get_block(build_pos[X] + 1, build_pos[Y], build_pos[Z])
					
					if (!build_edge[XN])
						discardblock = builder_get_block(build_pos[X] - 1, build_pos[Y], build_pos[Z])
					
					break
				}
				
				case "north":
				{
					if (!build_edge[XN])
						connectblock = builder_get_block(build_pos[X] - 1, build_pos[Y], build_pos[Z])
					
					if (!build_edge[XP])
						discardblock = builder_get_block(build_pos[X] + 1, build_pos[Y], build_pos[Z])
					
					break
				}
			}
			
			if (discardblock = block_current)
			{
				if (!staticmodel)
					return null

				type = "left"
				double = "true"
			}
			else if (connectblock = block_current)
			{
				type = "right"
				double = "true"
			}
			else
			{
				type = "single"
				double = "false"
			}

			if (staticmodel)
				block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "type", type)
		}
	}

	// Find connected block position
	if (build_get_connect)
	{
		if (double != "true" || block_current.name = "ender_chest")
			return null

		var offset = vec3(0);
		switch (facing)
		{
			case "north": offset[X] = -1; break
			case "south": offset[X] = 1; break
			case "east":  offset[Y] = -1; break
			case "west":  offset[Y] = 1; break
			default: return null
		}
		if (type = "left")
			offset = vec3_mul(offset, -1)

		var pos, state, othertype;
		pos = vec3_add(build_pos, offset)
		if (builder_get_block(pos[X], pos[Y], pos[Z]) != block_current)
			return null

		state = builder_get_state_id(pos[X], pos[Y], pos[Z])
		othertype = block_get_state_id_value(block_current, state, "type")
		if ((othertype = "single" && !legacy) ||
			block_get_state_id_value(block_current, state, "variant") != block_get_state_id_value(block_current, block_state_id_current, "variant"))
			return null

		if (!legacy && othertype != "legacy" &&
			(othertype != (type = "left" ? "right" : "left") || block_get_state_id_value(block_current, state, "facing") != facing))
			return null

		return pos
	}

	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "double", double)
	
	return 0
}
