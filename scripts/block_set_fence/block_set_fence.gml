/// block_set_fence()
/// @desc Connects to other fences with the same ID, fence gates and solid adjacent faces.
/*
for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	var dstr = dir_get_string(d);

	if (build_edge[d])
	{
		state_vars_set_value(vars, dstr, "false")
		continue
	}
		
	// Check for same fence
	var block = array3D_get(block_obj, build_size, point3D_add(build_pos, dir_get_vec3(d)));
	if (is_undefined(block))
	{
		state_vars_set_value(vars, dstr, "false")
		continue
	}
	
	if (block = block_current)
	{
		state_vars_set_value(vars, dstr, "true")
		continue
	}
		
	// Check for fence gate
	if (block.type = "fence_gate")
	{
		var facing = state_vars_get_value(array3D_get(block_state, build_size, point3D_add(build_pos, dir_get_vec3(d))), "facing");
		if (facing != dstr && facing != dir_get_string(dir_get_opposite(d)))
		{
			state_vars_set_value(vars, dstr, "true")
			continue
		}
	}
		
	// Check for solid faces
	if (block_render_models_dir[d] != null && block_render_models_get_solid_dir(block_render_models_dir[d], d))
		state_vars_set_value(vars, dstr, "true")
	else
		state_vars_set_value(vars, dstr, "false")
}

return 0*/