/// block_set_twisting_vines()
/// @desc Turns off wind if there is no twisting vines above.

function block_set_twisting_vines()
{
	if (!build_edge_zn)
	{
		var block = builder_get(block_obj, build_pos_x, build_pos_y, build_pos_z - 1);
		if (block == null || block.type != "twisting_vines")
			vertex_wave_zmin = block_pos_z
	}
	else
		vertex_wave_zmin = block_pos_z
	
	if ((builder_scenery && !builder_scenery_legacy) || block_get_state_id_value(block_current, block_state_id_current, "variant") = "twisting_vines_plant")
		return 0
	
	if (build_pos_z != (build_size_z - 1))
		block_state_id_current = block_get_state_id(block_current, array("variant", "twisting_vines_plant"))
	
	return 0
}
