/// snap(value, x)
/// @arg value
/// @arg x

function snap_floor(val, xx)
{
	if (xx = 0)
		return val
	
	return floor(val / xx) * xx
}
