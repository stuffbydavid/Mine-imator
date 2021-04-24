/// percent(value, start, end)
/// @arg value
/// @arg start
/// @arg end

function percent(value, s, e)
{
	if (s = e) 
		return (value < s)
	
	return clamp((value - s) / (e - s), 0, 1)
}
