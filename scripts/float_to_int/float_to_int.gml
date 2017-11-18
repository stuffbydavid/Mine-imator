/// float_to_int(x)
/// @arg x
/// @desc Removes the decimal point.

var xx = argument0;

if (xx < 0)
	return -floor(abs(xx))
else
	return floor(xx)