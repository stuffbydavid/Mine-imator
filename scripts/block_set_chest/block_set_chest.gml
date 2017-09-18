/// block_set_chest()
/// @desc Finds double chests.

var connectdir, discarddir;
switch (string_to_dir(vars[?"facing"]))
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

if (!build_edge[discarddir]) // Discard
	if (array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(discarddir))) = block_current)
		return null
		
vars[?"double"] = "false"

if (!build_edge[connectdir]) // Connect
	if (array3D_get(block_obj, point3D_add(build_pos, dir_get_vec3(connectdir))) = block_current)
		vars[?"double"] = "true"

return 0