/// @desc Resolves tall vine states and anchors wind at the base of the stack.
/// @arg variable
/// @arg value
/// @arg direction

function block_set_tall_vine(variable, value, dir)
{
	// Clear wind limits left by neighboring model resolution
	block_vertex_wave_zmin = null
	block_vertex_wave_zmax = null

	// Anchor wind opposite the growth direction
	var offset, support;
	offset = dir_get_vec3(dir)
	support = null
	
	if (!build_edge[dir ^ 1])
		support = builder_get_block(build_pos[X], build_pos[Y], build_pos[Z] - offset[Z])

	if (support = null || support.wind_axis = e_vertex_wave.NONE)
	{
		if (dir = ZP)
			block_vertex_wave_zmin = block_model_pos[Z]
		else
			block_vertex_wave_zmax = block_model_pos[Z] + block_size
	}
	
	// Edits choose the tip from the actual neighboring vine
	if (build_edit && !builder_scenery)
	{
		var nextvalue, state, neighbor;
		state = block_current.states_map[?variable]
		nextvalue = value
		neighbor = null
		
		if (!build_edge[dir])
			neighbor = builder_get_block(build_pos[X], build_pos[Y], build_pos[Z] + offset[Z])
		
		if (neighbor != block_current)
		{
			for (var v = 0; v < state.value_amount; v++)
			{
				if (state.value_name[v] != value)
				{
					nextvalue = state.value_name[v]
					break
				}
			}
		}
		
		block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, variable, nextvalue)
		return 0
	}

	if ((builder_scenery && !builder_scenery_legacy) || block_get_state_id_value(block_current, block_state_id_current, variable) = value)
		return 0
	
	if (!build_edge[dir])
		block_state_id_current = block_get_state_id(block_current, [ variable, value ])
	
	return 0
}
