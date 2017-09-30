/// block_set_snowy()
/// @desc Check for a snow block above the current block.

if (state_vars_get_value(vars, "snowy") != null)
	return 0

if (!build_edge[e_dir.UP])
{
	var block = array3D_get(block_obj, build_size, point3D_add(build_pos, dir_get_vec3(e_dir.UP)));
	
	if (!is_undefined(block) && block.type = "snow")
	{
		state_vars_set_value(vars, "snowy", "true")
		return 0
	}
}

state_vars_set_value(vars, "snowy", "false")

return 0