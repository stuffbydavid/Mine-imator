/// block_set_redstone_repeater()
/// @desc Set locked state.
/*
var facing, facingopp;
facing = string_to_dir(state_vars_get_value(vars, "facing"));
facingopp = dir_get_opposite(facing)

for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	if (d = facing || d = facingopp || build_edge[d])
		continue
		
	var block = array3D_get(block_obj, build_size, point3D_add(build_pos, dir_get_vec3(d)));
	if (is_undefined(block)) // Skip air
		continue
	
	var facing = state_vars_get_value(array3D_get(block_state, build_size, point3D_add(build_pos, dir_get_vec3(d))), "facing")
	if (block.name = "powered_repeater" && facing = dir_get_string(d))
	{
		state_vars_set_value(vars, "locked", "true")
		return 0
	}
}

state_vars_set_value(vars, "locked", "false")

return 0*/