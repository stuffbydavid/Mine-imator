/// block_set_fire()
/// @desc Locates non-air blocks.

var east, west, south, north, up;
east = "false"
west = "false"
south = "false"
north = "false"
up = "false"

if (!build_edge[e_dir.EAST])
{
	var block = array3D_get(block_obj, build_size_z, build_pos_x + 1, build_pos_y, build_pos_z);
	if (block != null && block != block_current)
		east = "true"
}

if (!build_edge[e_dir.WEST])
{
	var block = array3D_get(block_obj, build_size_z, build_pos_x - 1, build_pos_y, build_pos_z);
	if (block != null && block != block_current)
		west = "true"
}

if (!build_edge[e_dir.SOUTH])
{
	var block = array3D_get(block_obj, build_size_z, build_pos_x, build_pos_y + 1, build_pos_z);
	if (block != null && block != block_current)
		south = "true"
}

if (!build_edge[e_dir.NORTH])
{
	var block = array3D_get(block_obj, build_size_z, build_pos_x, build_pos_y - 1, build_pos_z);
	if (block != null && block != block_current)
		north = "true"
}

if (!build_edge[e_dir.UP])
{
	var block = array3D_get(block_obj, build_size_z, build_pos_x, build_pos_y, build_pos_z + 1);
	if (block != null && block != block_current)
		up = "true"
}

block_state_id_current = block_get_state_id(block_current, array("east", east, "west", west, "south", south, "north", north, "up", up))

return 0