/// block_set_redstone_wire()
/// @desc Connect to other redstone wires, or powered blocks facing the opposite direction

var pow, powreal, red;
pow = block_get_state_id_value(block_current, block_state_id_current, "power")
powreal = string_get_real(pow) / 15
if (powreal = 0)
	red = 0.3
else
	red = 0.6 * powreal + 0.4
	
block_color = make_color_rgb(red * 255, 0, 0)
vertex_brightness = powreal

var east, west, south, north;
east = "none"
west = "none"
south = "none"
north = "none"

// X+
if (!build_edge_xp)
{
	var block = array3D_get(block_obj, build_size_z, build_pos_x + 1, build_pos_y, build_pos_z); // Check side
	if (block != null)
	{
		// Connect to other redstone wire
		if (block = block_current || block.type = "redstone_connect")
			east = "side"
		else if (block.type = "redstone_repeater" || block.type = "redstone_comparator")
		{
			var facing = block_get_state_id_value(block, array3D_get(block_state_id, build_size_z, build_pos_x + 1, build_pos_y, build_pos_z), "facing");
			if (facing = "east" || facing = "west")
				east = "side"
		}
	}
	
	if (east = "none" && !build_edge_zp && !(block_face_min_depth_zp = e_block_depth.DEPTH0 && block_face_full_zp)) // Check up
	{
		block = array3D_get(block_obj, build_size_z, build_pos_x + 1, build_pos_y, build_pos_z + 1)
		if (block = block_current)
			east = "up"
	}
	
	if (east = "none" && !build_edge_zn && !(block_face_min_depth_xp = e_block_depth.DEPTH0 && block_face_full_xp)) // Check down
	{
		block = array3D_get(block_obj, build_size_z, build_pos_x + 1, build_pos_y, build_pos_z - 1)
		if (block = block_current)
			east = "side"
	}
}

// X-
if (!build_edge_xn)
{
	var block = array3D_get(block_obj, build_size_z, build_pos_x - 1, build_pos_y, build_pos_z); // Check side
	if (block != null)
	{
		// Connect to other redstone wire
		if (block = block_current || block.type = "redstone_connect")
			west = "side"
		else if (block.type = "redstone_repeater" || block.type = "redstone_comparator")
		{
			var facing = block_get_state_id_value(block, array3D_get(block_state_id, build_size_z, build_pos_x - 1, build_pos_y, build_pos_z), "facing");
			if (facing = "east" || facing = "west")
				west = "side"
		}
	}
	
	if (west = "none" && !build_edge_zp && !(block_face_min_depth_zp = e_block_depth.DEPTH0 && block_face_full_zp)) // Check up
	{
		block = array3D_get(block_obj, build_size_z, build_pos_x - 1, build_pos_y, build_pos_z + 1)
		if (block = block_current)
			west = "up"
	}
	
	if (west = "none" && !build_edge_zn && !(block_face_min_depth_xn = e_block_depth.DEPTH0 && block_face_full_xn)) // Check down
	{
		block = array3D_get(block_obj, build_size_z, build_pos_x - 1, build_pos_y, build_pos_z - 1)
		if (block = block_current)
			west = "side"
	}
}

// Y+
if (!build_edge_yp)
{
	var block = array3D_get(block_obj, build_size_z, build_pos_x, build_pos_y + 1, build_pos_z); // Check side
	if (block != null)
	{
		// Connect to other redstone wire
		if (block = block_current || block.type = "redstone_connect")
			south = "side"
		else if (block.type = "redstone_repeater" || block.type = "redstone_comparator")
		{
			var facing = block_get_state_id_value(block, array3D_get(block_state_id, build_size_z, build_pos_x, build_pos_y + 1, build_pos_z), "facing");
			if (facing = "south" || facing = "north")
				south = "side"
		}
	}
	
	if (south = "none" && !build_edge_zp && !(block_face_min_depth_zp = e_block_depth.DEPTH0 && block_face_full_zp)) // Check up
	{
		block = array3D_get(block_obj, build_size_z, build_pos_x, build_pos_y + 1, build_pos_z + 1)
		if (block = block_current)
			south = "up"
	}
	
	if (south = "none" && !build_edge_zn && !(block_face_min_depth_yp = e_block_depth.DEPTH0 && block_face_full_yp)) // Check down
	{
		block = array3D_get(block_obj, build_size_z, build_pos_x, build_pos_y + 1, build_pos_z - 1)
		if (block = block_current)
			south = "side"
	}
}

// Y-
if (!build_edge_yn)
{
	var block = array3D_get(block_obj, build_size_z, build_pos_x, build_pos_y - 1, build_pos_z); // Check side
	if (block != null)
	{
		// Connect to other redstone wire
		if (block = block_current || block.type = "redstone_connect")
			north = "side"
		else if (block.type = "redstone_repeater" || block.type = "redstone_comparator")
		{
			var facing = block_get_state_id_value(block, array3D_get(block_state_id, build_size_z, build_pos_x, build_pos_y - 1, build_pos_z), "facing");
			if (facing = "south" || facing = "north")
				north = "side"
		}
	}
	
	if (north = "none" && !build_edge_zp && !(block_face_min_depth_zp = e_block_depth.DEPTH0 && block_face_full_zp)) // Check up
	{
		block = array3D_get(block_obj, build_size_z, build_pos_x, build_pos_y - 1, build_pos_z + 1)
		if (block = block_current)
			north = "up"
	}
	
	if (north = "none" && !build_edge_zn && !(block_face_min_depth_yn = e_block_depth.DEPTH0 && block_face_full_yn)) // Check down
	{
		block = array3D_get(block_obj, build_size_z, build_pos_x, build_pos_y - 1, build_pos_z - 1)
		if (block = block_current)
			north = "side"
	}
}

block_state_id_current = block_get_state_id(block_current, array("east", east, "west", west, "south", south, "north", north, "power", pow))

return 0
