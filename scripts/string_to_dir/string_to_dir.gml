/// string_to_dir(string)
/// @arg string

function string_to_dir(str)
{
	switch (str)
	{
		case "east":	return e_dir.EAST
		case "west":	return e_dir.WEST
		case "south":	return e_dir.SOUTH
		case "north":	return e_dir.NORTH
		case "up":		return e_dir.UP
		case "down":	return e_dir.DOWN
	}
	
	return null
}
