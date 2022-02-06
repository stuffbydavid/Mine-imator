/// bezier_curve(p1, p2, p3, p4, t)
/// @arg p1
/// @arg p2
/// @arg p3
/// @arg p4
/// @arg t

function bezier_curve(p1, p2, p3, p4, t)
{
	var t1, t2, t3, t4, t5;
	t1 = point2D_lerp(p1, p2, t)
	t2 = point2D_lerp(p2, p3, t)
	t3 = point2D_lerp(p3, p4, t)
	
	t4 = point2D_lerp(t1, t2, t)
	t5 = point2D_lerp(t2, t3, t)
	
	return point2D_lerp(t4, t5, t)
}