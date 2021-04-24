/// vec2(x, y)
/// @arg x
/// @arg y

function vec2()
{
	var vec;
	
	if (argument_count = 1)
	{
		vec[X] = argument[0]
		vec[Y] = argument[0]
	} 
	else
	{
		vec[X] = argument[0]
		vec[Y] = argument[1]
	}
	
	return vec
}
