/// block_set_vines()
/// @desc Connects to non-air blocks above.

vars[?"up"] = "false"

if (build_edge[e_dir.UP])
	return 0
	
var bid = array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(e_dir.UP)));
if (bid > 0 && bid != block_id_current)
	vars[?"up"] = "true"

return 0