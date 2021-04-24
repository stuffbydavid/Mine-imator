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
	
	return 0
}
