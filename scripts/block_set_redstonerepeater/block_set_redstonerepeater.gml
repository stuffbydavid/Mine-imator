/// block_set_redstonerepeater()
/// @desc Set locked state.

var facing, facingopp;
facing = string_to_dir(vars[?"facing"]);
facingopp = dir_get_opposite(facing)

vars[?"locked"] = "false"

for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
{
	if (d = facing || d = facingopp || build_edge[d])
		continue
		
	var bid = array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(d)));
	if (bid = 0) // Skip air
		continue
	
	var block = mc_version.block_map[?bid];
	if (!is_undefined(block))
	{
		var bdata = array3D_get(block_data, point3D_add(build_pos, dir_get_vec3(d))),
			datavars = block.data_vars[bdata];
				
		if (block.data_name[bdata]= "redstonerepeateractive" && datavars != null &&
			!is_undefined(datavars[?"facing"]) && datavars[?"facing"] = dir_get_string(d))
			vars[?"locked"] = "true"
	}
}

return 0