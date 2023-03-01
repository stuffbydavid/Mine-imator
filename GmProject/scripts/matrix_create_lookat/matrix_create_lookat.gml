/// matrix_create_lookat(from, to, up)
/// @arg from
/// @arg to
/// @arg up
/// @desc Built-in GameMaker function has NaN issues, do it manually.

function matrix_create_lookat(from, to, up)
{
	var forward, right;
	forward = vec3_direction(from, to)
	right = vec3_normalize(vec3_cross(up, forward))
	up = vec3_normalize(vec3_cross(forward, right))
	
	return	[right[X],  up[X], forward[X], 0,
			 right[Y],  up[Y], forward[Y], 0,
			 right[Z],  up[Z], forward[Z], 0,
			 -vec3_dot(right, from), -vec3_dot(up, from), -vec3_dot(forward, from), 1]
}