/// dir_get_string(direction)
/// @arg direction

function dir_get_string(dir)
{
	switch (dir)
	{
		case e_dir.EAST:	return "east"
		case e_dir.WEST:	return "west"
		case e_dir.SOUTH:	return "south"
		case e_dir.NORTH:	return "north"
		case e_dir.UP:		return "up"
		case e_dir.DOWN:	return "down"
	}
	
	return ""
}
