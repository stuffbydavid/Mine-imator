/// block_set_chorus_plant()
/// @desc Connects to other chorus plants, chorus flowers and end stone below.
/*
for (var d = 0; d <= e_dir.amount; d++)
{
	var dstr = dir_get_string(d);

	if (build_edge[d])
	{
		state_vars_set_value(vars, dstr, "false")
		continue
	}
		
	// Check for chorus plant/flower
	var block = array3D_get(block_obj, build_size, point3D_add(build_pos, dir_get_vec3(d)));
	if (is_undefined(block)) // Skip air
	{
		state_vars_set_value(vars, dstr, "false")
		continue
	}
		
	if (block = block_current || block.type = "chorus_plant_connect")
	{
		state_vars_set_value(vars, dstr, "true")
		continue
	}
	
	// Check for end stone
	if (d = e_dir.DOWN)
	{
		block = array3D_get(block_obj, build_size, point3D_add(build_pos, dir_get_vec3(d)));
		if (!is_undefined(block) && block.name = "end_stone")
		{
			state_vars_set_value(vars, dstr, "true")
			continue
		}
	}
	
	state_vars_set_value(vars, dstr, "false")
}

return 0*/