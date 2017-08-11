/// block_set_fire()
/// @desc Locates non-air blocks.

for (var d = 0; d < e_dir.amount; d++)
{
	var dstr = dir_get_string(d);
	vars[?dstr] = "false"

	if (build_edge[d])
		continue
		
	// Check non-air block
	var block = array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(d)));
	if (!is_undefined(block))
		vars[?dstr] = "true"
}	