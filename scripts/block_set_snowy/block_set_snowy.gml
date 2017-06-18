/// block_set_snowy()
/// @desc Check for a snow block above the current block.

vars[?"snowy"] = "false"

if (!build_edge[e_dir.UP])
{
	var aboveid, abovedata;
	aboveid = array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(e_dir.UP)))
	abovedata = array3D_get(block_data, point3D_add(build_pos, dir_get_vec3(e_dir.UP)))
	
	if (!is_undefined(mc_version.block_map[?aboveid]))
		if (mc_version.block_map[?aboveid].data_type[abovedata] = "snow")
			vars[?"snowy"] = "true"
}

return 0