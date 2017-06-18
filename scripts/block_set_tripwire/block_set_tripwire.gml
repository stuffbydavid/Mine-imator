/// block_set_tripwire()

for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	var dstr = dir_get_string(d);
	vars[?dstr] = "false"

	if (build_edge[d])
		continue
	
	var bid = array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(d)));
	if (bid = 0) // Skip air
		continue
		
	// Check for other tripwire or hooks
	var bdata, block;
	bdata = array3D_get(block_data, point3D_add(build_pos, dir_get_vec3(d)))
	block = mc_version.block_map[?bid];
	if (!is_undefined(block))
		if (block.data_type[bdata] = "tripwire" || block.data_name[bdata] = "tripwirehook")
			vars[?dstr] = "true"
}

return 0