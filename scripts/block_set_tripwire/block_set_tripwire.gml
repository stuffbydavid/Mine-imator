/// block_set_tripwire()

for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	var dstr = dir_get_string(d);
	vars[?dstr] = "false"

	if (build_edge[d])
		continue
	
	var block = array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(d)));
	if (is_undefined(block)) // Skip air
		continue
		
	// Check for other tripwire or hooks
	if (block.name = "tripwire" || block.name = "tripwire_hook")
		vars[?dstr] = "true"
}

return 0