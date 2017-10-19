/// block_set_vine()
/// @desc Connects to non-air blocks above.

var up = "false";

if (!build_edge_zp)
{
	var block = builder_get(block_obj, build_pos_x, build_pos_y, build_pos_z + 1);
	if (block != null && block != block_current)
		up = "true"
}

block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "up", up)

return 0