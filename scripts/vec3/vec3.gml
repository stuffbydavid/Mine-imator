/// vec3(x, y, z)
/// @arg x
/// @arg y
/// @arg z

function vec3()
{
	var vec;

	if (argument_count = 1)
	{
		vec[X] = argument[0]
		vec[Y] = argument[0]
		vec[Z] = argument[0]
	}
	else
	{
		vec[X] = argument[0]
		vec[Y] = argument[1]
		vec[Z] = argument[2]
	}
	
	return vec
}
