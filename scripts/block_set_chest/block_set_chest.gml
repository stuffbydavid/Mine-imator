/// block_set_chest()
/// @desc Finds double chests.

var facing, connectdir, discarddir;
facing = block_get_state_id_value(block_current, block_state_id_current, "facing");

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

if (!build_edge[discarddir] && array3D_get(block_obj, build_size_z, point3D_add(build_pos, dir_get_vec3(discarddir))) = block_current) // Discard
	return null
		
var double = "false"
if (!build_edge[connectdir] && array3D_get(block_obj, build_size_z, point3D_add(build_pos, dir_get_vec3(connectdir))) = block_current) // Connect
	double = "true"

block_state_id_current = block_get_state_id(block_current, array("facing", facing, "double", double))

return 0