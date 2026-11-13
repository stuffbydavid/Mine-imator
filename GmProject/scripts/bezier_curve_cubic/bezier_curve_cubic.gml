/// @desc Returns result of a cubic bezier curve.
/// @arg point1
/// @arg point2
/// @arg point3
/// @arg point4
/// @arg progress

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
