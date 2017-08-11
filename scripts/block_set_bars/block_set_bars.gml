/// block_set_bars()
/// @desc Connects to other bars and panes or solid faces.

for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	var dstr = dir_get_string(d);
	vars[?dstr] = "false"

	if (build_edge[d])
		continue
	
	// Check for other bars
	var block = array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(d)));
	if (!is_undefined(block) && block.type = "bars")
	{
		vars[?dstr] = "true"
		continue
	}
	
	// Check for solid faces
	if (block_render_models_dir[d] != null && block_render_models_get_solid_dir(block_render_models_dir[d], d))
		vars[?dstr] = "true"
}

return 0