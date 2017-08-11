/// block_set_fence_gate()
/// @desc Connects to fences and cobblestone walls in the same direction.

if (is_undefined(vars[?"facing"]))
	return 0
	
var block;

vars[?"in_wall"] = "false"
	
if (vars[?"facing"] = "east" || vars[?"facing"] = "west")
{
	// Check south for wall
	if (!build_edge[e_dir.SOUTH])
	{
		block = array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(e_dir.SOUTH)))
		if (!is_undefined(block) && block.type = "wall")
		{
			vars[?"in_wall"] = "true"
			return 0
		}
	}
	
	// Check north for wall
	if (!build_edge[e_dir.NORTH])
	{
		block = array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(e_dir.NORTH)))
		if (!is_undefined(block) && block.type = "wall")
		{
			vars[?"in_wall"] = "true"
			return 0
		}
	}
}
else if (vars[?"facing"] = "south" || vars[?"facing"] = "north")
{
	// Check east for wall
	if (!build_edge[e_dir.EAST])
	{
		block = array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(e_dir.EAST)))
		if (!is_undefined(block) && block.type = "wall")
		{
			vars[?"in_wall"] = "true"
			return 0
		}
	}
	
	// Check west for wall
	if (!build_edge[e_dir.WEST])
	{
		block = array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(e_dir.WEST)))
		if (!is_undefined(block) && block.type = "wall")
		{
			vars[?"in_wall"] = "true"
			return 0
		}
	}
}

return 0