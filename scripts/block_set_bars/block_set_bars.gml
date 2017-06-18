/// block_set_bars()
/// @desc Connects to other bars and panes or solid faces.

for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	var dstr = dir_get_string(d);
	vars[?dstr] = "false"

	if (build_edge[d])
		continue
	
	// Check for other bars
	var bid = array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(d)));
	if (bid = 0) // Skip air
		continue
		
	var block = mc_version.block_map[?bid];
	if (!is_undefined(block))
	{
		var bdata = array3D_get(block_data, point3D_add(build_pos, dir_get_vec3(d)));
		if (block.data_type[bdata] = "bars")
		{
			vars[?dstr] = "true"
			continue
		}
	}
	
	// Check for solid faces
	if (block_render_models_dir[d] != null && block_render_models_get_solid_dir(block_render_models_dir[d], d))
		vars[?dstr] = "true"
}

return 0