/// block_set_fence()
/// @desc Connects to other fences with the same ID, fence gates and solid adjacent faces.

for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	var dstr = dir_get_string(d);
	vars[?dstr] = "false"

	if (build_edge[d])
		continue
		
	// Check for same fence
	var block = array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(d)));
	if (is_undefined(block))
		continue
	
	if (block = block_current)
	{
		vars[?dstr] = "true"
		continue
	}
		
	// Check for fence gate
	if (block.type = "fence_gate")
	{
		var facing = block_vars_get_value(array3D_get(block_state, point3D_add(build_pos, dir_get_vec3(d))), "facing");
		if (facing != dstr && facing != dir_get_string(dir_get_opposite(d)))
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