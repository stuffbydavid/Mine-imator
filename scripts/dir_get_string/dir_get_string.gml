/// dir_get_string(direction)
/// @arg direction

//gml_pragma("forceinline")

switch (argument0)
{
	case e_dir.EAST:	return "east"
	case e_dir.WEST:	return "west"
	case e_dir.SOUTH:	return "south"
	case e_dir.NORTH:	return "north"
	case e_dir.UP:		return "up"
	case e_dir.DOWN:	return "down"
}

return ""