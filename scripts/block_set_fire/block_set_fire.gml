/// block_set_fire()
/// @desc Locates non-air blocks.

for (var d = 0; d < e_dir.amount; d++)
{
	var dstr = dir_get_string(d);
	vars[?dstr] = "false"

	if (build_edge[d])
		continue
		
	// Check non-air block
	var bid = array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(d)));
	if (bid > 0)
		vars[?dstr] = "true"
}	