/// block_set_vine()
/// @desc Connects to non-air blocks above.
/*
if (build_edge[e_dir.UP])
{
	state_vars_set_value(vars, "up", "false")
	return 0
}
	
var block = array3D_get(block_obj, build_size, point3D_add(build_pos, dir_get_vec3(e_dir.UP)));
if (!is_undefined(block) && block != block_current)
{
	state_vars_set_value(vars, "up", "true")
	return 0
}

state_vars_set_value(vars, "up", "false")

return 0*/