/// block_set_fence()
/// @desc Connects to other fences with the same material, fence gates and solid adjacent faces.

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
		if (block.type = block_current.type) // Same fences/walls
			east = "true"
		else if (block.type = "fence_gate") // Fence gates
		{
			var facing = block_get_state_id_value(block, array3D_get(block_state_id, build_size_z, build_pos_x + 1, build_pos_y, build_pos_z), "facing")
			if (facing != "east" && facing != "west")
				east = "true"
		}
		else // Check solid
		{
			var model = array3D_get(block_render_model, build_size_z, build_pos_x + 1, build_pos_y, build_pos_z);
			if (model != null && !is_array(model) && model.face_min_depth_xn = e_block_depth.DEPTH0 && model.face_full_xn)
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
		if (block.type = block_current.type) // Same fences/walls
			west = "true"
		else if (block.type = "fence_gate") // Fence gates
		{
			var facing = block_get_state_id_value(block, array3D_get(block_state_id, build_size_z, build_pos_x - 1, build_pos_y, build_pos_z), "facing")
			if (facing != "east" && facing != "west")
				west = "true"
		}
		else // Check solid
		{
			var model = array3D_get(block_render_model, build_size_z, build_pos_x - 1, build_pos_y, build_pos_z);
			if (model != null && !is_array(model) && model.face_min_depth_xp = e_block_depth.DEPTH0 && model.face_full_xp)
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
		if (block.type = block_current.type) // Same fences/walls
			south = "true"
		else if (block.type = "fence_gate") // Fence gates
		{
			var facing = block_get_state_id_value(block, array3D_get(block_state_id, build_size_z, build_pos_x, build_pos_y + 1, build_pos_z), "facing")
			if (facing != "south" && facing != "north")
				south = "true"
		}
		else // Check solid
		{
			var model = array3D_get(block_render_model, build_size_z, build_pos_x, build_pos_y + 1, build_pos_z);
			if (model != null && !is_array(model) && model.face_min_depth_yn = e_block_depth.DEPTH0 && model.face_full_yn)
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
		if (block.type = block_current.type) // Same fences/walls
			north = "true"
		else if (block.type = "fence_gate") // Fence gates
		{
			var facing = block_get_state_id_value(block, array3D_get(block_state_id, build_size_z, build_pos_x, build_pos_y - 1, build_pos_z), "facing")
			if (facing != "south" && facing != "north")
				north = "true"
		}
		else // Check solid
		{
			var model = array3D_get(block_render_model, build_size_z, build_pos_x, build_pos_y - 1, build_pos_z);
			if (model != null && !is_array(model) && model.face_min_depth_yp = e_block_depth.DEPTH0 && model.face_full_yp)
				north = "true"
		}
	}
}

if (block_current.type = "wall")
{
	var variant, up;
	variant = block_get_state_id_value(block_current, block_state_id_current, "variant")
	if ((east && west && !south && !north) || (!east && !west && south && north))
		up = "false"
	else
		up = "true"
	
	block_state_id_current = block_get_state_id(block_current, array("variant", variant, "east", east, "west", west, "south", south, "north", north, "up", up))
}
else
	block_state_id_current = block_get_state_id(block_current, array("east", east, "west", west, "south", south, "north", north))

return 0