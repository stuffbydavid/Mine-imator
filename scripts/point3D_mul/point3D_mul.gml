/// point3D_mul(point, multiplier)
/// @arg point
/// @arg multiplier

var pnt, mul;
pnt = argument0
mul = argument1

if (is_array(mul))
	return point3D(pnt[@ X] * mul[@ X], pnt[@ Y] * mul[@ Y], pnt[@ Z] * mul[@ Z])
else
	return point3D(pnt[@ X] * mul, pnt[@ Y] * mul, pnt[@ Z] * mul)