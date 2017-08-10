/// block_set_redstone_wire()
/// @desc Connect to other redstone wires, or powered blocks facing the opposite direction

var pow, red;
pow = block_data_current / 15
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
	vars[?dstr] = "none"
	
	if (build_edge[d])
		continue
	
	// Sides
	var bid = array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(d)));
	
	// Connect to other redstone wire
	if (bid = block_id_current)
	{
		vars[?dstr] = "side"
		continue
	}
	
	// Check for input/outputs
	else if (bid > 0)
	{
		var block = mc_version.block_map[?bid];
		if (!is_undefined(block))
		{
			var bdata = array3D_get(block_data, point3D_add(build_pos, dir_get_vec3(d))),
				datavars = block.data_vars[bdata],
				doppstr = dir_get_string(dir_get_opposite(d));
		
			// Check for a redstone powered block
			if (block.data_type[bdata] = "redstone_connect" || 
				((block.data_type[bdata] = "redstone_repeater" || block.data_type[bdata] = "redstone_comparator") &&
				 datavars != null && !is_undefined(datavars[?"facing"]) && (datavars[?"facing"] = dstr || datavars[?"facing"] = doppstr)))
			{
				vars[?dstr] = "side"
				continue
			}
		}
	}
	
	// Down
	if (!build_edge[e_dir.DOWN])
	{
		bid = array3D_get(block_id, point3D_add(build_pos, vec3_add(dir_get_vec3(d), vec3(0, 0, -1))))
		if (bid = block_id_current && (block_render_models_dir[d] = null || !block_render_models_get_solid(block_render_models_dir[d])))
		{
			vars[?dstr] = "side"
			continue
		}
	}
	
	// Up
	if (!build_edge[e_dir.UP])
	{
		bid = array3D_get(block_id, point3D_add(build_pos, vec3_add(dir_get_vec3(d), vec3(0, 0, 1))))
		if (bid = block_id_current && (block_render_models_dir[e_dir.UP] = null || !block_render_models_get_solid(block_render_models_dir[e_dir.UP])))
		{
			vars[?dstr] = "up"
			continue
		}
	}
}

return 0