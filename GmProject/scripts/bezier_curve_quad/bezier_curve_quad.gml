/// @desc Returns result of a quadratic bezier curve.
/// @arg point1
/// @arg point2
/// @arg point3
/// @arg progress

function bezier_curve_quad(p1, p2, p3, t)
{
	var t1, t2;
	t1 = point_lerp(p1, p2, t)
	t2 = point_lerp(p2, p3, t)
	
	return point_lerp(t1, t2, t)
}
