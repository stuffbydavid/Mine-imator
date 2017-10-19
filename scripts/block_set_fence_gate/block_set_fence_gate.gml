/// block_set_fence_gate()
/// @desc Connects to fences and cobblestone walls in the same direction.

var block, facing, inwall;
facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
inwall = "false"

if (facing = "east" || facing = "west")
{
	// Check south for wall
	if (!build_edge_yp)
	{
		block = builder_get(block_obj, build_pos_x, build_pos_y + 1, build_pos_z)
		if (block != null && block.type = "wall")
			inwall = "true"
	}
	
	// Check north for wall
	if (inwall = "false" && !build_edge_yn)
	{
		block = builder_get(block_obj, build_pos_x, build_pos_y - 1, build_pos_z)
		if (block != null && block.type = "wall")
			inwall = "true"
	}
}
else if (facing = "south" || facing = "north")
{
	// Check east for wall
	if (!build_edge_xp)
	{
		block = builder_get(block_obj, build_pos_x + 1, build_pos_y, build_pos_z)
		if (block != null && block.type = "wall")
			inwall = "true"
	}
	
	// Check west for wall
	if (inwall = "false" && !build_edge_xn)
	{
		block = builder_get(block_obj, build_pos_x - 1, build_pos_y, build_pos_z)
		if (block != null && block.type = "wall")
			inwall = "true"
	}
}

block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "in_wall", inwall)

return 0