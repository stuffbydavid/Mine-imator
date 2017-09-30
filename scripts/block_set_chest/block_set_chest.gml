/// block_set_chest()
/// @desc Finds double chests.

var facing = state_vars_get_value(vars, "facing");
if (facing = null)
	return 0

var connectdir, discarddir;
switch (string_to_dir(facing))
{
	case e_dir.EAST:
	{
		connectdir = e_dir.NORTH
		discarddir = e_dir.SOUTH
		break
	}
	
	case e_dir.WEST:
	{
		connectdir = e_dir.SOUTH
		discarddir = e_dir.NORTH
		break
	}
	
	case e_dir.SOUTH:
	{
		connectdir = e_dir.EAST
		discarddir = e_dir.WEST
		break
	}
	
	case e_dir.NORTH:
	{
		connectdir = e_dir.WEST
		discarddir = e_dir.EAST
		break
	}
}

if (!build_edge[discarddir] && array3D_get(block_obj, build_size, point3D_add(build_pos, dir_get_vec3(discarddir))) = block_current) // Discard
	return null
		
if (!build_edge[connectdir] && array3D_get(block_obj, build_size, point3D_add(build_pos, dir_get_vec3(connectdir))) = block_current) // Connect
	state_vars_set_value(vars, "double", "true")
else
	state_vars_set_value(vars, "double", "false")

return 0