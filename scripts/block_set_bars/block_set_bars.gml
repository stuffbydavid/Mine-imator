/// block_set_bars()
/// @desc Connects to other bars and panes or solid faces.
/*
for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	var dstr = dir_get_string(d);

	if (build_edge[d])
	{
		state_vars_set_value(vars, dstr, "false")
		continue
	}
	
	// Check for other bars
	var block = array3D_get(block_obj, build_size, point3D_add(build_pos, dir_get_vec3(d)));
	if (!is_undefined(block) && block.type = "bars")
	{
		state_vars_set_value(vars, dstr, "true")
		continue
	}
	
	// Check for solid faces
	if (block_render_models_dir[d] != null && block_render_models_get_solid_dir(block_render_models_dir[d], d))
	{
		state_vars_set_value(vars, dstr, "true")
		continue
	}
	
	state_vars_set_value(vars, dstr, "false")
}

return 0*/