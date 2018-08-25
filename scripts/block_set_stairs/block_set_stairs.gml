/// block_set_stairs()
/// @desc Defines logic for connecting adjacent stairs.

var shape, half, facing;
shape = "straight"
half = block_get_state_id_value(block_current, block_state_id_current, "half")
facing = block_get_state_id_value(block_current, block_state_id_current, "facing")

// X+
if (!build_edge_xp && (facing = "east" || facing = "west"))
{
	var block = builder_get(block_obj, build_pos_x + 1, build_pos_y, build_pos_z);
	if (block != null && block.type = "stairs")
	{
		var stateid = builder_get(block_state_id, build_pos_x + 1, build_pos_y, build_pos_z);
		if (block_get_state_id_value(block, stateid, "half") = half) // Same half
		{
			var otherfacing = block_get_state_id_value(block, stateid, "facing");
			if (facing = "east")
			{
				if (otherfacing = "south")
					shape = "outer_right"
				else if (otherfacing = "north")
					shape = "outer_left"
			}
			else // West
			{
				if (otherfacing = "south")
					shape = "inner_left"
				else if (otherfacing = "north")
					shape = "inner_right"
			}
		}
	}
}

// X-
if (!build_edge_xn && (facing = "east" || facing = "west"))
{
	var block = builder_get(block_obj, build_pos_x - 1, build_pos_y, build_pos_z);
	if (block != null && block.type = "stairs")
	{
		var stateid = builder_get(block_state_id, build_pos_x - 1, build_pos_y, build_pos_z);
		if (block_get_state_id_value(block, stateid, "half") = half) // Same half
		{
			var otherfacing = block_get_state_id_value(block, stateid, "facing");
			if (facing = "east")
			{
				if (otherfacing = "south")
					shape = "inner_right"
				else if (otherfacing = "north")
					shape = "inner_left"
			}
			else // West
			{
				if (otherfacing = "south")
					shape = "outer_left"
				else if (otherfacing = "north")
					shape = "outer_right"
			}
		}
	}
}

// Y+
if (!build_edge_yp && (facing = "south" || facing = "north"))
{
	var block = builder_get(block_obj, build_pos_x, build_pos_y + 1, build_pos_z);
	if (block != null && block.type = "stairs")
	{
		var stateid = builder_get(block_state_id, build_pos_x, build_pos_y + 1, build_pos_z);
		if (block_get_state_id_value(block, stateid, "half") = half) // Same half
		{
			var otherfacing = block_get_state_id_value(block, stateid, "facing");
			if (facing = "south")
			{
				if (otherfacing = "east")
					shape = "outer_left"
				else if (otherfacing = "west")
					shape = "outer_right"
			}
			else // North
			{
				if (otherfacing = "east")
					shape = "inner_right"
				else if (otherfacing = "west")
					shape = "inner_left"
			}
		}
	}
}

// Y-
if (!build_edge_yn && (facing = "south" || facing = "north"))
{
	var block = builder_get(block_obj, build_pos_x, build_pos_y - 1, build_pos_z);
	if (block != null && block.type = "stairs")
	{
		var stateid = builder_get(block_state_id, build_pos_x, build_pos_y - 1, build_pos_z);
		if (block_get_state_id_value(block, stateid, "half") = half) // Same half
		{
			var otherfacing = block_get_state_id_value(block, stateid, "facing");
			if (facing = "south")
			{
				if (otherfacing = "east")
					shape = "inner_left"
				else if (otherfacing = "west")
					shape = "inner_right"
			}
			else // North
			{
				if (otherfacing = "east")
					shape = "outer_right"
				else if (otherfacing = "west")
					shape = "outer_left"
			}
		}
	}
}

if (shape != "straight")
	block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "shape", shape)
	
return 0