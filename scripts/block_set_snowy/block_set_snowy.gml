/// block_set_snowy()
/// @desc Check for a snow block above the current block.

if (!is_undefined(vars[?"snowy"]))
	return 0

vars[?"snowy"] = "false"

if (!build_edge[e_dir.UP])
{
	var block = array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(e_dir.UP)));
	
	if (!is_undefined(block) && block.type = "snow")
		vars[?"snowy"] = "true"
}

return 0