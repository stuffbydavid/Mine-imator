/// @desc Turns off wind on the top of the block stack if there is no windy block above.

function block_set_tall_vine_down(variable, value)
{
	if (!build_edge[ZP])
	{
		var upblock = builder_get_block(build_pos[X], build_pos[Y], build_pos[Z] + 1);
		if (upblock = null || upblock.wind_axis = e_vertex_wave.NONE)
			block_vertex_wave_zmax = block_model_pos[Z] + block_size
	}
	else
		block_vertex_wave_zmax = block_model_pos[Z] + block_size
	
	if ((builder_scenery && !builder_scenery_legacy) || block_get_state_id_value(block_current, block_state_id_current, variable) = value)
		return 0
	
	if (!build_edge[ZN])
		block_state_id_current = block_get_state_id(block_current, [ variable, value ])
	
	return 0
}
