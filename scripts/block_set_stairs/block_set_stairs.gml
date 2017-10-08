/// block_set_stairs()
/// @desc Defines logic for connecting adjacent stairs.
/*
if (state_vars_get_value(vars, "shape") != null)
	return 0

var half, facing, facingopp, shape;
half = state_vars_get_value(vars, "half")
facing = string_to_dir(state_vars_get_value(vars, "facing"))
facingopp = dir_get_opposite(facing)
shape = "straight"

for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	// Check in facing axis
	if (d != facing && d != facingopp)
		continue
		
	// Ignore edge
	if (build_edge[d])
		continue
		
	// Check for stairs
	var block = array3D_get(block_obj, build_size, point3D_add(build_pos, dir_get_vec3(d)));
	if (is_undefined(block) || block.type != "stairs")
		continue
		
	// Check same half
	var state = array3D_get(block_state, build_size, point3D_add(build_pos, dir_get_vec3(d)));
	if (half != state_vars_get_value(state, "half"))
		continue
		
	var otherfacing = string_to_dir(state_vars_get_value(state, "facing"));
	
	// Looking east
	if (d = e_dir.EAST)
	{
		if (facing = e_dir.EAST)
		{
			if (otherfacing = e_dir.SOUTH)
				shape = "outer_right"
			else if (otherfacing = e_dir.NORTH)
				shape = "outer_left"
		}
		else // West
		{
			if (otherfacing = e_dir.SOUTH)
				shape = "inner_left"
			else if (otherfacing = e_dir.NORTH)
				shape = "inner_right"
		}
	}
	
	// Looking west
	else if (d = e_dir.WEST)
	{
		if (facing = e_dir.EAST)
		{
			if (otherfacing = e_dir.SOUTH)
				shape = "inner_right"
			else if (otherfacing = e_dir.NORTH)
				shape = "inner_left"
		}
		else // West
		{
			if (otherfacing = e_dir.SOUTH)
				shape = "outer_left"
			else if (otherfacing = e_dir.NORTH)
				shape = "outer_right"
		}
	}
	
	// Looking south
	else if (d = e_dir.SOUTH)
	{
		if (facing = e_dir.SOUTH)
		{
			if (otherfacing = e_dir.EAST)
				shape = "outer_left"
			else if (otherfacing = e_dir.WEST)
				shape = "outer_right"
		}
		else // North
		{
			if (otherfacing = e_dir.EAST)
				shape = "inner_right"
			else if (otherfacing = e_dir.WEST)
				shape = "inner_left"
		}
	}
	
	// Looking north
	else
	{
		if (facing = e_dir.SOUTH)
		{
			if (otherfacing = e_dir.EAST)
				shape = "inner_left"
			else if (otherfacing = e_dir.WEST)
				shape = "inner_right"
		}
		else // North
		{
			if (otherfacing = e_dir.EAST)
				shape = "outer_right"
			else if (otherfacing = e_dir.WEST)
				shape = "outer_left"
		}
	}
}

state_vars_set_value(vars, "shape", shape)*/