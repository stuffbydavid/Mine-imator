/// block_set_redstone_wire()
/// @desc Connect to other redstone wires, or powered blocks facing the opposite direction

var pow, red;
pow = string_get_real(state_vars_get_value(vars, "power")) / 15
if (pow = 0)
	red = 0.3
else
	red = 0.6 * pow + 0.4
	
block_color = make_color_rgb(red * 255, 0, 0)
vertex_brightness = pow

// Check each direction for connections
for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	var dstr = dir_get_string(d);
	
	if (build_edge[d])
	{
		state_vars_set_value(vars, dstr, "none")
		continue
	}
	
	// Sides
	var block = array3D_get(block_obj, build_size, point3D_add(build_pos, dir_get_vec3(d)));
	
	// Connect to other redstone wire
	if (block = block_current)
	{
		state_vars_set_value(vars, dstr, "side")
		continue
	}
	
	// Check for input/outputs
	else if (!is_undefined(block))
	{
		var facing = state_vars_get_value(array3D_get(block_state, build_size, point3D_add(build_pos, dir_get_vec3(d))), "facing"),
			doppstr = dir_get_string(dir_get_opposite(d));
		
		// Check for a redstone powered block
		if (block.type = "redstone_connect" || 
			((block.type = "redstone_repeater" || block.type = "redstone_comparator") &&
			(facing = dstr || facing = doppstr)))
		{
			state_vars_set_value(vars, dstr, "side")
			continue
		}
	}
	
	// Down
	if (!build_edge[e_dir.DOWN])
	{
		block = array3D_get(block_obj, build_size, point3D_add(build_pos, vec3_add(dir_get_vec3(d), vec3(0, 0, -1))))
		if (block = block_current && (block_render_models_dir[d] = null || !block_render_models_get_solid(block_render_models_dir[d])))
		{
			state_vars_set_value(vars, dstr, "side")
			continue
		}
	}
	
	// Up
	if (!build_edge[e_dir.UP])
	{
		block = array3D_get(block_obj, build_size, point3D_add(build_pos, vec3_add(dir_get_vec3(d), vec3(0, 0, 1))))
		if (block = block_current && (block_render_models_dir[e_dir.UP] = null || !block_render_models_get_solid(block_render_models_dir[e_dir.UP])))
		{
			state_vars_set_value(vars, dstr, "up")
			continue
		}
	}
	
	state_vars_set_value(vars, dstr, "none")
}

return 0