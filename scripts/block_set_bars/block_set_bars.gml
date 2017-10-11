/// block_set_bars()
/// @desc Connects to other bars and panes or solid faces.

var east, west, south, north;
east = "false"
west = "false"
south = "false"
north = "false"

// X+
if (!build_edge[e_dir.EAST])
{
	var block = array3D_get(block_obj, build_size_z, build_pos_x + 1, build_pos_y, build_pos_z);
	if (block != null)
	{
		// Check for other bars
		if (block.type = "bars")
			east = "true"
		else
		{
			// Check solid
			var model = array3D_get(block_render_model, build_size_z, build_pos_x + 1, build_pos_y, build_pos_z);
			if (model != null && !is_array(model) && model.face_min_depth_xn != e_block_depth.DEPTH1 && model.face_full_xn)
				east = "true"
		}
	}
}

// X-
if (!build_edge[e_dir.WEST])
{
	var block = array3D_get(block_obj, build_size_z, build_pos_x - 1, build_pos_y, build_pos_z);
	if (block != null)
	{
		// Check for other bars
		if (block.type = "bars")
			west = "true"
		else
		{
			// Check solid
			var model = array3D_get(block_render_model, build_size_z, build_pos_x - 1, build_pos_y, build_pos_z);
			if (model != null && !is_array(model) && model.face_min_depth_xp != e_block_depth.DEPTH1 && model.face_full_xp)
				west = "true"
		}
	}
}

// Y+
if (!build_edge[e_dir.SOUTH])
{
	var block = array3D_get(block_obj, build_size_z, build_pos_x, build_pos_y + 1, build_pos_z);
	if (block != null)
	{
		// Check for other bars
		if (block.type = "bars")
			south = "true"
		else
		{
			// Check solid
			var model = array3D_get(block_render_model, build_size_z, build_pos_x, build_pos_y + 1, build_pos_z);
			if (model != null && !is_array(model) && model.face_min_depth_yn != e_block_depth.DEPTH1 && model.face_full_yn)
				south = "true"
		}
	}
}

// Y-
if (!build_edge[e_dir.NORTH])
{
	var block = array3D_get(block_obj, build_size_z, build_pos_x, build_pos_y - 1, build_pos_z);
	if (block != null)
	{
		// Check for other bars
		if (block.type = "bars")
			north = "true"
		else
		{
			// Check solid
			var model = array3D_get(block_render_model, build_size_z, build_pos_x, build_pos_y - 1, build_pos_z);
			if (model != null && !is_array(model) && model.face_min_depth_yp != e_block_depth.DEPTH1 && model.face_full_yp)
				north = "true"
		}
	}
}

block_state_id_current = block_get_state_id(block_current, array("east", east, "west", west, "south", south, "north", north))

return 0