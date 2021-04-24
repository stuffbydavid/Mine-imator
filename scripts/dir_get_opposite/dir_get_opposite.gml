/// dir_get_opposite(direction)
/// @arg direction

function dir_get_opposite(dir)
{
	switch (dir)
	{
		case e_dir.EAST:	return e_dir.WEST
		case e_dir.WEST:	return e_dir.EAST
		case e_dir.SOUTH:	return e_dir.NORTH
		case e_dir.NORTH:	return e_dir.SOUTH
		case e_dir.UP:		return e_dir.DOWN
		case e_dir.DOWN:	return e_dir.UP
	}
	
	return null
}
