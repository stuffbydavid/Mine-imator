/// float_to_int(x)
/// @arg x
/// @desc Removes the decimal point.

function float_to_int(xx)
{
	if (xx < 0)
		return -floor(abs(xx))
	else
		return floor(xx)
}
