/// @desc Returns a position, previous state ID and next block data for an interaction, or
///	null if not applicable for the block.
/// @arg block
/// @arg stateid
/// @arg target
/// @arg position
/// @arg [selected]
/// @arg [placeonly]

function block_build_use(block, stateid, target, blockpos, selected = null, placeonly = false)
{
	// Block needs a build JSON object
	if (block.build_map = null)
		return null

	// Select root block position for tall blocks
	if (blockpos != null && block_get_state_id_value(block, stateid, "half") = "upper")
	{
		var lowerpos, lowerdata;
		lowerpos = vec3_sub(blockpos, vec3(0, 0, 1))
		lowerdata = block_build_get_block(target, lowerpos)
		
		if (lowerdata[0] = block.block_id)
		{
			blockpos = lowerpos
			stateid = lowerdata[1]
		}
	}

	// Resolve legacy door state from combined data of two halves
	if (blockpos != null && !placeonly && block.type = "door")
	{
		with (target)
		{
			if (type = e_tl_type.SCENERY && temp != null && temp.scenery != null)
			{
				var ext = filename_ext(temp.scenery.filename);
				if (ext = ".schematic" || ext = ".blocks")
				{
					var resolved = block_meshes_get_block(blockpos[X], blockpos[Y], blockpos[Z], false, true);
					if (resolved[0] = block.block_id)
						stateid = resolved[1]
				}
			}
		}
	}

	var previous = stateid;
	if (selected != null && selected[0] = block.block_id && block.build_map[?"place"] = "slab")
	{
		var half, normal;
		half = block_get_state_id_value(block, stateid, "type")
		normal = vec3_mul_matrix(place_view_world_normal, matrix_inverse_ext(target.matrix_render))

		if (block_get_state_id_value(block, selected[1], "variant") = block_get_state_id_value(block, stateid, "variant") &&
			abs(normal[Z]) > max(abs(normal[X]), abs(normal[Y])) &&
			((half = "bottom" && normal[Z] > 0) || (half = "top" && normal[Z] < 0)))
		{
			return [ blockpos, previous, [ block.block_id, block_set_state_id_value(block, stateid, "type", "double") ] ]
		}
	}

	if (placeonly)
		return null

	// Specific block needed for use
	var usewith = value_get_string(block.build_map[?"use_with"], "")
	if (selected != null && usewith != "")
	{
		var selblock, selstate;
		selblock = block_objs[selected[0]]
		selstate = selected[1]
		
		// Use candle on cake
		if (usewith = "candle" && selblock.name = "candle" && block_get_state_id_value(block, stateid, "bites") = "0")
			return [ blockpos, previous, [ block.block_id, block_set_state_id_value(block, stateid, "candle", block_get_state_id_value(selblock, selstate, "color")) ] ]

		// Use flower on flower pot
		if (usewith = "contents")
		{
			var contents, states;
			contents = block_get_minecraft_name(selblock, selstate)
			states = block.states_map[?"contents"]
			if (ds_map_exists(states.value_map, contents))
				return [ blockpos, previous, [ block.block_id, block_set_state_id_value(block, stateid, "contents", contents) ] ]
		}
	}

	var use = block.build_map[?"use"];
	
	// Toggle values
	if (is_string(use))
	{
		var state, index;
		state = block.states_map[?use]
		if (is_undefined(state))
			return null
		
		index = (stateid div state.value_id) mod state.value_amount
		if (index = state.value_amount - 1 && value_get_real(block.build_map[?"use_remove"], false))
			return [ blockpos, previous, [ 0, 0 ] ]

		stateid = block_set_state_id_value(block, stateid, use, state.value_name[(index + 1) mod state.value_amount])
		if (is_string(block.build_map[?"use_clear"]))
		{
			var vars = block_get_state_id_state_vars(block, stateid);
			state_vars_add(vars, string_get_state_vars(block.build_map[?"use_clear"]))
			stateid = block_get_state_id(block, vars)
		}
		
		return [ blockpos, previous, [ block.block_id, stateid ] ]
	}
	
	// Toggle value combinations
	if (ds_list_valid(use))
	{
		var next = 0;
		for (var i = 0; i < ds_list_size(use); i++)
		{
			if (state_vars_match_state_id(string_get_state_vars(use[|i]), block, stateid))
			{
				next = (i + 1) mod ds_list_size(use)
				break
			}
		}
		
		var vars = block_get_state_id_state_vars(block, stateid);
		state_vars_add(vars, string_get_state_vars(use[|next]))
		
		return [ blockpos, previous, [ block.block_id, block_get_state_id(block, vars) ] ]
	}

	return null
}
