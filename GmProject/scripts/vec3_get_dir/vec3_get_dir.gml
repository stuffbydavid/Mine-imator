/// @desc Returns the closest allowed direction to a vector.
/// @arg vector
/// @arg [directions]

function vec3_get_dir(vec, dirs = dir_names)
{
	var dir, prevdot;
	dir = ZP
	prevdot = -vec3_length(vec) - 1
	
	for (var d = XP; d <= ZN; d++)
	{
		if (!array_contains(dirs, dir_names[d]))
			continue

		var dot = vec3_dot(vec, dir_get_vec3(d));
		if (dot > prevdot)
		{
			dir = d
			prevdot = dot
		}
	}

	return dir
}
