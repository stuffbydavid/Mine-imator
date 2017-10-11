/// block_set_redstone_wire()
/// @desc Connect to other redstone wires, or powered blocks facing the opposite direction

var pow, powreal, red, dirstate;
dirstate = array("none", "none", "none", "none");
pow = block_get_state_id_value(block_current, block_state_id_current, "power")
powreal = string_get_real(pow) / 15
if (powreal = 0)
	red = 0.3
else
	red = 0.6 * powreal + 0.4
	
block_color = make_color_rgb(red * 255, 0, 0)
vertex_brightness = powreal

// Check each direction for connections
for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	if (build_edge[d])
		continue
	
	// Sides
	var block = array3D_get(block_obj, build_size_z, point3D_add(build_pos, dir_get_vec3(d)));
	if (block != null)
	{
		// Connect to other redstone wire
		if (block = block_current || block.type = "redstone_connect")
		{
			dirstate[d] = "side"
			continue
		}
		else if (block.type = "redstone_repeater" || block.type = "redstone_comparator")
		{
			var facing = string_to_dir(block_get_state_id_value(block, array3D_get(block_state_id, build_size_z, point3D_add(build_pos, dir_get_vec3(d))), "facing"));
			if (facing = d || facing = dir_get_opposite(d))
			{
				dirstate[d] = "side"
				continue
			}
		}
		
	}
	
	// Down
	if (!build_edge[e_dir.DOWN])
	{
		block = array3D_get(block_obj, build_size_z, point3D_add(build_pos, vec3_add(dir_get_vec3(d), vec3(0, 0, -1))))
		if (block = block_current)
		{
			var issolid;
			switch (d)
			{
				case e_dir.EAST:	issolid = (block_face_min_depth_xp = e_block_depth.DEPTH0 && block_face_full_xp); break
				case e_dir.WEST:	issolid = (block_face_min_depth_xn = e_block_depth.DEPTH0 && block_face_full_xn); break
				case e_dir.SOUTH:	issolid = (block_face_min_depth_yp = e_block_depth.DEPTH0 && block_face_full_yp); break
				case e_dir.NORTH:	issolid = (block_face_min_depth_yn = e_block_depth.DEPTH0 && block_face_full_yn); break
			}
			
			if (!issolid)
			{
				dirstate[d] = "side"
				continue
			}
		}
	}
	
	// Up
	if (!build_edge[e_dir.UP])
	{
		block = array3D_get(block_obj, build_size_z, point3D_add(build_pos, vec3_add(dir_get_vec3(d), vec3(0, 0, 1))))
		if (block = block_current && !(block_face_min_depth_zp = e_block_depth.DEPTH0 && block_face_full_zp))
		{
			dirstate[d] = "up"
			continue
		}
	}
}

block_state_id_current = block_get_state_id(block_current, array("east", dirstate[e_dir.EAST], "west", dirstate[e_dir.WEST], "south", dirstate[e_dir.SOUTH], "north", dirstate[e_dir.NORTH], "power", string(pow)))

return 0
