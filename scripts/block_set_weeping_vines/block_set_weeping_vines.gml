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

return 0