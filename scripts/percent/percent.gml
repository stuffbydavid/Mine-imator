/// percent(value, start, end, [clamp])
/// @arg value
/// @arg start
/// @arg end
/// @arg [clamp]

function percent(value, s, e, limit = true)
{
	if (s = e) 
		return (value < s)
	
	if (limit)
		return clamp((value - s) / (e - s), 0, 1)
	else
		return (value - s) / (e - s)
}
