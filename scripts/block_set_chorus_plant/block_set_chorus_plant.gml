/// block_set_chorus_plant()
/// @desc Connects to other chorus plants, chorus flowers and end stone below.

var east, west, south, north, down;
east = "false"
west = "false"
south = "false"
north = "false"
down = "false"

if (!build_edge_xp)
{
	var block = builder_get(block_obj, build_pos_x + 1, build_pos_y, build_pos_z);
	if (block != null && (block = block_current || block.type = "chorus_plant_connect"))
		east = "true"
}

if (!build_edge_xn)
{
	var block = builder_get(block_obj, build_pos_x - 1, build_pos_y, build_pos_z);
	if (block != null && (block = block_current || block.type = "chorus_plant_connect"))
		west = "true"
}

if (!build_edge_yp)
{
	var block = builder_get(block_obj, build_pos_x, build_pos_y + 1, build_pos_z);
	if (block != null && (block = block_current || block.type = "chorus_plant_connect"))
		south = "true"
}

if (!build_edge_yn)
{
	var block = builder_get(block_obj, build_pos_x, build_pos_y - 1, build_pos_z);
	if (block != null && (block = block_current || block.type = "chorus_plant_connect"))
		north = "true"
}

if (!build_edge_zn)
{
	var block = builder_get(block_obj, build_pos_x, build_pos_y, build_pos_z - 1);
	if (block != null && (block = block_current || block.type = "chorus_plant_connect" || block.name = "end_stone"))
		down = "true"
}

block_state_id_current = block_get_state_id(block_current, array("east", east, "west", west, "south", south, "north", north, "down", down))

return 0