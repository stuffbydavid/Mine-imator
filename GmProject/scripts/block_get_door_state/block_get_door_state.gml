/// @desc Resolves the door hinge position and direction used by timeline transforms.
/// @arg block
/// @arg stateid

function block_get_door_state(block, stateid)
{
	var hinge, facing, open, location, dir;
	hinge = block_get_state_id_value(block, stateid, "hinge")
	facing = block_get_state_id_value(block, stateid, "facing")
	open = block_get_state_id_value(block, stateid, "open")

	// Set values for position/rotation
	if (facing = "east")
	{
		location = (hinge = "right" ? "south_west" : "north_west")
		if (open = "false")
			dir = (hinge = "right" ? "north" : "south")
	}
	else if (facing = "west")
	{
		location = (hinge = "right" ? "north_east" : "south_east")
		if (open = "false")
			dir = (hinge = "right" ? "south" : "north")
	}
	else if (facing = "south")
	{
		location = (hinge = "right" ? "north_west" : "north_east")
		if (open = "false")
			dir = (hinge = "right" ? "east" : "west")
	}
	else if (facing = "north")
	{
		location = (hinge = "right" ? "south_east" : "south_west")
		if (open = "false")
			dir = (hinge = "right" ? "west" : "east")
	}
	
	if (open = "true")
		dir = facing
		
	stateid = block_set_state_id_value(block, stateid, "location", location)
	return block_set_state_id_value(block, stateid, "direction", dir)
}
