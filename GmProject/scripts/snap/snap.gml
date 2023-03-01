/// snap(value, x)
/// @arg value
/// @arg x

function snap(val, xx)
{
	if (xx = 0)
		return val
	
	return round(val / xx) * xx
}
