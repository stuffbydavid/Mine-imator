/// dir_get_vec3(direction)
/// @arg direction

function dir_get_vec3(dir)
{
	switch (dir)
	{
		case e_dir.EAST:	return vec3(1, 0, 0)
		case e_dir.WEST:	return vec3(-1, 0, 0)
		case e_dir.SOUTH:	return vec3(0, 1, 0)
		case e_dir.NORTH:	return vec3(0, -1, 0)
		case e_dir.UP:		return vec3(0, 0, 1)
		case e_dir.DOWN:	return vec3(0, 0, -1)
	}
	
	return vec3(0, 0, 0)
}
