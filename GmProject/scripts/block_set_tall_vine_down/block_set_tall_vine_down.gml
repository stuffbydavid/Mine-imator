/// block_set_tall_vine_down()
/// @desc Turns off wind on the top of the block stack if there is no windy block above.

function block_set_tall_vine_down(variable, value)
{
	if (!build_edge_zp)
	{
		var upblock = builder_get_block(build_pos_x, build_pos_y, build_pos_z + 1);
		if (upblock = null || upblock.wind_axis = e_vertex_wave.NONE)
			block_vertex_wave_zmax = block_pos_z + block_size
	}
	else
		block_vertex_wave_zmax = block_pos_z + block_size
	
	if ((builder_scenery && !builder_scenery_legacy) || block_get_state_id_value(block_current, block_state_id_current, variable) = value)
		return 0
	
	if (build_pos_z != 0)
		block_state_id_current = block_get_state_id(block_current, array(variable, value))
	
	return 0
}
