/// block_set_weeping_vines()
/// @desc Turns off wind if there is no weeping vines above.

if (!build_edge_zp)
{
	var block = builder_get(block_obj, build_pos_x, build_pos_y, build_pos_z + 1);
	if (block == null || block.type != "weeping_vines")
		vertex_wave_zmax = block_pos_z + block_size
}
else
	vertex_wave_zmax = block_pos_z + block_size

if ((builder_scenery && !builder_scenery_legacy) || block_get_state_id_value(block_current, block_state_id_current, "variant") = "weeping_vines_plant")
	return 0

if (build_pos_z = 0)
	block_state_id_current = block_get_state_id(block_current, array("variant", "weeping_vines"))
else
	block_state_id_current = block_get_state_id(block_current, array("variant", "weeping_vines_plant"))

return 0