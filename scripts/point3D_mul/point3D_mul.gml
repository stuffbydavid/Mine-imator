/// point3D_mul(point, multiplier)
/// @arg point
/// @arg multiplier

function point3D_mul(pnt, mul)
{
	if (is_array(mul))
		return point3D(pnt[@ X] * mul[@ X], pnt[@ Y] * mul[@ Y], pnt[@ Z] * mul[@ Z])
	else
		return point3D(pnt[@ X] * mul, pnt[@ Y] * mul, pnt[@ Z] * mul)
}
