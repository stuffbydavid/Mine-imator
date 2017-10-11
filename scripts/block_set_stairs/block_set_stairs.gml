/// block_set_stairs()
/// @desc Defines logic for connecting adjacent stairs.

var shape, half, facing, facingdir, facingoppdir;
shape = "straight"
half = block_get_state_id_value(block_current, block_state_id_current, "half")
facing = block_get_state_id_value(block_current, block_state_id_current, "facing")
facingdir = string_to_dir(facing)
facingoppdir = dir_get_opposite(facingdir)

for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	// Check in facingdir axis
	if (d != facingdir && d != facingoppdir)
		continue
		
	// Ignore edge
	if (build_edge[d])
		continue
		
	// Check for stairs
	var otherblock = array3D_get(block_obj, build_size_z, point3D_add(build_pos, dir_get_vec3(d)));
	if (otherblock = null || otherblock.type != "stairs")
		continue
		
	// Check same half
	var otherstateid, otherhalf;
	otherstateid = array3D_get(block_state_id, build_size_z, point3D_add(build_pos, dir_get_vec3(d)));
	otherhalf = block_get_state_id_value(otherblock, otherstateid, "half")
	if (half != otherhalf)
		continue
		
	var otherfacingdir = string_to_dir(block_get_state_id_value(otherblock, otherstateid, "facing"));
	
	// Looking east
	switch (d)
	{
		case e_dir.EAST:
		{
			if (facingdir = e_dir.EAST)
			{
				if (otherfacingdir = e_dir.SOUTH)
					shape = "outer_right"
				else if (otherfacingdir = e_dir.NORTH)
					shape = "outer_left"
			}
			else // West
			{
				if (otherfacingdir = e_dir.SOUTH)
					shape = "inner_left"
				else if (otherfacingdir = e_dir.NORTH)
					shape = "inner_right"
			}
			break
		}
	
		// Looking west
		case e_dir.WEST:
		{
			if (facingdir = e_dir.EAST)
			{
				if (otherfacingdir = e_dir.SOUTH)
					shape = "inner_right"
				else if (otherfacingdir = e_dir.NORTH)
					shape = "inner_left"
			}
			else // West
			{
				if (otherfacingdir = e_dir.SOUTH)
					shape = "outer_left"
				else if (otherfacingdir = e_dir.NORTH)
					shape = "outer_right"
			}
			break
		}
	
		// Looking south
		case e_dir.SOUTH:
		{
			if (facingdir = e_dir.SOUTH)
			{
				if (otherfacingdir = e_dir.EAST)
					shape = "outer_left"
				else if (otherfacingdir = e_dir.WEST)
					shape = "outer_right"
			}
			else // North
			{
				if (otherfacingdir = e_dir.EAST)
					shape = "inner_right"
				else if (otherfacingdir = e_dir.WEST)
					shape = "inner_left"
			}
			break
		}
	
		// Looking north
		case e_dir.NORTH:
		{
			if (facingdir = e_dir.SOUTH)
			{
				if (otherfacingdir = e_dir.EAST)
					shape = "inner_left"
				else if (otherfacingdir = e_dir.WEST)
					shape = "inner_right"
			}
			else // North
			{
				if (otherfacingdir = e_dir.EAST)
					shape = "outer_right"
				else if (otherfacingdir = e_dir.WEST)
					shape = "outer_left"
			}
			break
		}
	}
}

if (shape != "straight")
	block_state_id_current = block_get_state_id(block_current, array("shape", shape, "half", half, "facing", facing))
	
return 0