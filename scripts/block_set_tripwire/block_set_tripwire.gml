/// block_set_tripwire()
/*
for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	var dstr = dir_get_string(d);

	if (build_edge[d])
	{
		state_vars_set_value(vars, dstr, "false")
		continue
	}
	
	var block = array3D_get(block_obj, build_size, point3D_add(build_pos, dir_get_vec3(d)));
	if (is_undefined(block)) // Skip air
	{
		state_vars_set_value(vars, dstr, "false")
		continue
	}
		
	// Check for other tripwire or hooks
	if (block.name = "tripwire" || block.name = "tripwire_hook")
	{
		state_vars_set_value(vars, dstr, "true")
		continue
	}
	
	state_vars_set_value(vars, dstr, "false")
}

return 0*/