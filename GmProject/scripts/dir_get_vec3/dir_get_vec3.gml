/// @arg direction

function dir_get_vec3(dir)
{
	switch (dir)
	{
		case XP: return vec3(1, 0, 0)
		case XN: return vec3(-1, 0, 0)
		case YP: return vec3(0, 1, 0)
		case YN: return vec3(0, -1, 0)
		case ZP: return vec3(0, 0, 1)
		case ZN: return vec3(0, 0, -1)
	}
	
	return vec3(0, 0, 0)
}
