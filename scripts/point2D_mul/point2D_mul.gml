/// point2D_mul(point, multiplier)
/// @arg point
/// @arg multiplier

var pnt, mul;
pnt = argument0
mul = argument1

if (is_array(mul))
	return point2D(pnt[@ X] * mul[@ X], pnt[@ Y] * mul[@ Y])
else
	return point2D(pnt[@ X] * mul, pnt[@ Y] * mul)