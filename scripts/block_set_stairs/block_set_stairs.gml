/// block_set_stairs()

vars[?"shape"] = "straight"

var facing, facingopp;
facing = string_to_dir(vars[?"facing"])
facingopp = dir_get_opposite(string_to_dir(vars[?"facing"]))

for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	// Check in facing axis
	if (d != facing && d != facingopp)
		continue
		
	// Check for stairs
	var block = array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(d)));
	if (is_undefined(block) || block.type != "stairs")
		continue
		
	// Check same half
	var state = array3D_get(block_state, point3D_add(build_pos, dir_get_vec3(d)));
	if (vars[?"half"] != block_vars_get_value(state, "half"))
		continue
		
	var otherfacing = string_to_dir(block_vars_get_value(state, "facing"));
	
	// Looking east
	if (d = e_dir.EAST)
	{
		if (facing = e_dir.EAST)
		{
			if (otherfacing = e_dir.SOUTH)
				vars[?"shape"] = "outer_right"
			else if (otherfacing = e_dir.NORTH)
				vars[?"shape"] = "outer_left"
		}
		else // West
		{
			if (otherfacing = e_dir.SOUTH)
				vars[?"shape"] = "inner_left"
			else if (otherfacing = e_dir.NORTH)
				vars[?"shape"] = "inner_right"
		}
	}
	
	// Looking west
	else if (d = e_dir.WEST)
	{
		if (facing = e_dir.EAST)
		{
			if (otherfacing = e_dir.SOUTH)
				vars[?"shape"] = "inner_right"
			else if (otherfacing = e_dir.NORTH)
				vars[?"shape"] = "inner_left"
		}
		else // West
		{
			if (otherfacing = e_dir.SOUTH)
				vars[?"shape"] = "outer_left"
			else if (otherfacing = e_dir.NORTH)
				vars[?"shape"] = "outer_right"
		}
	}
	
	// Looking south
	else if (d = e_dir.SOUTH)
	{
		if (facing = e_dir.SOUTH)
		{
			if (otherfacing = e_dir.EAST)
				vars[?"shape"] = "outer_left"
			else if (otherfacing = e_dir.WEST)
				vars[?"shape"] = "outer_right"
		}
		else // North
		{
			if (otherfacing = e_dir.EAST)
				vars[?"shape"] = "inner_right"
			else if (otherfacing = e_dir.WEST)
				vars[?"shape"] = "inner_left"
		}
	}
	
	// Looking north
	else
	{
		if (facing = e_dir.SOUTH)
		{
			if (otherfacing = e_dir.EAST)
				vars[?"shape"] = "inner_left"
			else if (otherfacing = e_dir.WEST)
				vars[?"shape"] = "inner_right"
		}
		else // North
		{
			if (otherfacing = e_dir.EAST)
				vars[?"shape"] = "outer_right"
			else if (otherfacing = e_dir.WEST)
				vars[?"shape"] = "outer_left"
		}
	}
}