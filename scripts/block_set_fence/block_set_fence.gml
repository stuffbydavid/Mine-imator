/// block_set_fence()
/// @desc Connects to other fences with the same ID, fence gates and solid adjacent faces.

for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	var dstr = dir_get_string(d);
	vars[?dstr] = "false"

	if (build_edge[d])
		continue
		
	// Check for same fence
	var bid = array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(d)));
	if (bid = block_id_current)
	{
		vars[?dstr] = "true"
		continue
	}
	else if (bid = 0) // Skip air
		continue
		
	// Check for fence gate
	var bdata, block, opp;
	bdata = array3D_get(block_data, point3D_add(build_pos, dir_get_vec3(d)))
	block = mc_version.block_map[?bid];
	opp = dir_get_opposite(d)
	if (!is_undefined(block) && block.data_type[bdata] = "fencegate")
	{
		var datavars = block.data_vars[bdata];
		if (datavars != null)
		{
			var facing = datavars[? "facing"];
			if (!is_undefined(facing) && facing != dstr && facing != dir_get_string(opp))
			{
				vars[?dstr] = "true"
				continue
			}
		}
	}
		
	// Check for solid faces
	if (block_render_models_dir[d] != null && block_render_models_get_solid_dir(block_render_models_dir[d], d))
		vars[?dstr] = "true"
}

return 0