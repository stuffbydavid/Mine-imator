/// block_set_chest()
/// @desc Finds double chests.

var facing, connectblock, discardblock, double;
facing = block_get_state_id_value(block_current, block_state_id_current, "facing");
connectblock = null
discardblock = null

switch (facing)
{
	case "east":
	{
		if (!build_edge_yn)
			connectblock = builder_get(block_obj, build_pos_x, build_pos_y - 1, build_pos_z)
		if (!build_edge_yp)
			discardblock = builder_get(block_obj, build_pos_x, build_pos_y + 1, build_pos_z)
		break
	}
	
	case "west":
	{
		if (!build_edge_yp)
			connectblock = builder_get(block_obj, build_pos_x, build_pos_y + 1, build_pos_z)
		if (!build_edge_yn)
			discardblock = builder_get(block_obj, build_pos_x, build_pos_y - 1, build_pos_z)
		break
	}
	
	case "south":
	{
		if (!build_edge_xp)
			connectblock = builder_get(block_obj, build_pos_x + 1, build_pos_y, build_pos_z)
		if (!build_edge_xn)
			discardblock = builder_get(block_obj, build_pos_x - 1, build_pos_y, build_pos_z)
		break
	}
	
	case "north":
	{
		if (!build_edge_xn)
			connectblock = builder_get(block_obj, build_pos_x - 1, build_pos_y, build_pos_z)
		if (!build_edge_xp)
			discardblock = builder_get(block_obj, build_pos_x + 1, build_pos_y, build_pos_z)
		break
	}
}

if (discardblock = block_current) // Discard
	return null
		
if (connectblock = block_current) // Connect
	double = "true"
else
	double = "false"

block_state_id_current = block_get_state_id(block_current, array("facing", facing, "double", double))

return 0