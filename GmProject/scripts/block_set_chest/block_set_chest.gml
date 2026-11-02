/// @desc Finds double chests.

function block_set_chest()
{
	var type, double, staticmodel, facing;
	type = block_get_state_id_value(block_current, block_state_id_current, "type")
	facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
	double = "false"
	staticmodel = (builder_mode = e_builder_mode.GET_CONNECT || builder_mode = e_builder_mode.RESOLVE_STATE || !mc_builder.block_tl_add || block_tl_map = null)

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
				var offsets, neighbors, pair, origin, paired, blocked, face;
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
					if (dir_names[d] = facing)
						face = d
				
				if (blocked[face] && !blocked[face ^ 1])
					facing = dir_names[face ^ 1]
				
				block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "facing", facing)
			}
			
			var connected = block_get_connect(block_current, block_set_state_id_value(block_current, block_state_id_current, "type", "right"));
			if (connected != null)
			{
				var offset, dir, pos;
				offset = connected[0]
				dir = vec3_get_dir(offset)
				
				if (!build_edge[dir])
				{
					pos = vec3_add(build_pos, offset)
					connectblock = builder_get_block(pos[X], pos[Y], pos[Z])
				}

				if (!build_edge[dir ^ 1])
				{
					pos = vec3_sub(build_pos, offset)
					discardblock = builder_get_block(pos[X], pos[Y], pos[Z])
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
	if (builder_mode = e_builder_mode.GET_CONNECT)
	{
		if (double != "true" || block_current.name = "ender_chest")
			return null

		var connected = block_get_connect(block_current, block_state_id_current);
		if (connected = null)
			return null

		var pos, state, othertype;
		pos = vec3_add(build_pos, connected[0])
		if (builder_get_block(pos[X], pos[Y], pos[Z]) != block_current)
			return null

		state = builder_get_state_id(pos[X], pos[Y], pos[Z])
		othertype = block_get_state_id_value(block_current, state, "type")
		if ((othertype = "single" && !legacy) ||
			block_get_state_id_value(block_current, state, "variant") != block_get_state_id_value(block_current, block_state_id_current, "variant"))
			return null

		if (!legacy && othertype != "legacy" &&
			(othertype != block_get_state_id_value(block_current, connected[1], "type") || block_get_state_id_value(block_current, state, "facing") != facing))
			return null

		return pos
	}

	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "double", double)
	
	return 0
}
