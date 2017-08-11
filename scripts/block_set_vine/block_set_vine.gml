/// block_set_vine()
/// @desc Connects to non-air blocks above.

vars[?"up"] = "false"

if (build_edge[e_dir.UP])
	return 0
	
var block = array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(e_dir.UP)));
if (!is_undefined(block) && block != block_current)
	vars[?"up"] = "true"

return 0