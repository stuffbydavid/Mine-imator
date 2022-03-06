/// bezier_curve_quad(p1, p2, p3, t)
/// @arg p1
/// @arg p2
/// @arg p3
/// @arg t
/// @desc Returns result of a quadratic bezier curve.

function bezier_curve_quad(p1, p2, p3, t)
{
	var t1, t2;
	t1 = point_lerp(p1, p2, t)
	t2 = point_lerp(p2, p3, t)
	
	return point_lerp(t1, t2, t)
}