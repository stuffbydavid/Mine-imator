/// block_set_cave_vines()
/// @desc Turns off wind if there is no cave vines above.

function block_set_cave_vines()
{
	if (!build_edge_zp)
	{
		var block = builder_get_block(build_pos_x, build_pos_y, build_pos_z + 1);
		if (block == null || block.type != "cave_vines")
			vertex_wave_zmax = block_pos_z + block_size
	}
	else
		vertex_wave_zmax = block_pos_z + block_size
	
	if ((builder_scenery && !builder_scenery_legacy) || block_get_state_id_value(block_current, block_state_id_current, "type") = "cave_vines_plant")
		return 0
	
	var berries = block_get_state_id_value(block_current, block_state_id_current, "berries");
	
	if (build_pos_z = 0)
		block_state_id_current = block_get_state_id(block_current, array("type", "cave_vines", "berries", berries))
	else
		block_state_id_current = block_get_state_id(block_current, array("type", "cave_vines_plant", "berries", berries))
	
	return 0
}