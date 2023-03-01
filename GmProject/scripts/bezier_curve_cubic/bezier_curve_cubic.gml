/// bezier_curve_cubic(p1, p2, p3, p4, t)
/// @arg p1
/// @arg p2
/// @arg p3
/// @arg p4
/// @arg t
/// @desc Returns result of a cubic bezier curve.

function bezier_curve_cubic(p1, p2, p3, p4, t)
{
	var t1, t2, t3, t4, t5;
	t1 = point_lerp(p1, p2, t)
	t2 = point_lerp(p2, p3, t)
	t3 = point_lerp(p3, p4, t)
	
	t4 = point_lerp(t1, t2, t)
	t5 = point_lerp(t2, t3, t)
	
	return point_lerp(t4, t5, t)
}