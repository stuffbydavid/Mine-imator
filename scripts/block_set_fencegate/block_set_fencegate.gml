/// block_set_fencegate()
/// @desc Connects to fences and cobblestone walls in the same direction.

if (is_undefined(vars[?"facing"]))
	return 0
	
var bid, bdata;

vars[?"in_wall"] = "false"
	
if (vars[?"facing"] = "east" || vars[?"facing"] = "west")
{
	if (!build_edge[e_dir.SOUTH])
	{
		// Check south for wall
		bid = array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(e_dir.SOUTH)))
		if (bid > 0 && !is_undefined(mc_version.block_map[?bid]))
		{
			bdata = array3D_get(block_data, point3D_add(build_pos, dir_get_vec3(e_dir.SOUTH)))
			if (mc_version.block_map[?bid].data_type[bdata] = "wall")
			{
				vars[?"in_wall"] = "true"
				return 0
			}
		}
	}
	
	// Check north for wall
	if (!build_edge[e_dir.NORTH])
	{
		bid = array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(e_dir.NORTH)))
		if (bid > 0 && !is_undefined(mc_version.block_map[?bid]))
		{
			bdata = array3D_get(block_data, point3D_add(build_pos, dir_get_vec3(e_dir.NORTH)))
			if (mc_version.block_map[?bid].data_type[bdata] = "wall")
			{
				vars[?"in_wall"] = "true"
				return 0
			}
		}
	}
}
else if (vars[?"facing"] = "south" || vars[?"facing"] = "north")
{
	// Check east for wall
	if (!build_edge[e_dir.EAST])
	{
		bid = array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(e_dir.EAST)))
		if (bid > 0 && !is_undefined(mc_version.block_map[?bid]))
		{
			bdata = array3D_get(block_data, point3D_add(build_pos, dir_get_vec3(e_dir.EAST)))
			if (mc_version.block_map[?bid].data_type[bdata] = "wall")
			{
				vars[?"in_wall"] = "true"
				return 0
			}
		}
	}
	
	// Check west for wall
	if (!build_edge[e_dir.WEST])
	{
		bid = array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(e_dir.WEST)))
		if (bid > 0 && !is_undefined(mc_version.block_map[?bid]))
		{
			bdata = array3D_get(block_data, point3D_add(build_pos, dir_get_vec3(e_dir.WEST)))
			if (mc_version.block_map[?bid].data_type[bdata] = "wall")
			{
				vars[?"in_wall"] = "true"
				return 0
			}
		}
	}
}

return 0