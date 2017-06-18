/// block_set_chorusplant()
/// @desc Connects to other chorus plants, chorus flowers and end stone below.

for (var d = 0; d <= e_dir.amount; d++)
{
	var dstr = dir_get_string(d);
	vars[?dstr] = "false"

	if (build_edge[d])
		continue
		
	// Check for chorus plant
	var bid = array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(d)));
	if (bid = block_id_current)
	{
		vars[?dstr] = "true"
		continue
	}
	else if (bid = 0) // Skip air
		continue
		
	// Check for chorus flower
	var bdata, block;
	bdata = array3D_get(block_data, point3D_add(build_pos, dir_get_vec3(d)))
	block = mc_version.block_map[?bid];
	if (!is_undefined(block) && block.data_type[bdata] = "chorusplantconnect")
	{
		vars[?dstr] = "true"
		continue
	}
	
	// Check for end stone
	if (d = e_dir.DOWN)
	{
		bid = array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(d)));
		bdata = array3D_get(block_data, point3D_add(build_pos, dir_get_vec3(d)))
		block = mc_version.block_map[?bid];
		if (!is_undefined(block) && block.data_name[bdata] = "endstone")
			vars[?dstr] = "true"
	}
}

return 0