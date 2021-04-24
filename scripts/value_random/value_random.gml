/// value_random(value, israndom, randommin, randommax)
/// @arg value
/// @arg israndom
/// @arg randommin
/// @arg randommax

function value_random(val, israndom, randommin, randommax)
{
	if (israndom)
		return random_range(randommin, randommax)
	
	return val
}
