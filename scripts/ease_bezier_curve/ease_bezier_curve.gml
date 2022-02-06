/// ease_bezier_curve(p1, p2, p3, p4, t)
/// @arg p1
/// @arg p2
/// @arg p3
/// @arg p4
/// @arg t

function ease_bezier_curve(p1, p2, p3, p4, t)
{
	if (t = 0 || t = 1)
		return t
	
	var lower, upper, perc, curve, xx, xxprev;
	lower = 0
	upper = 1
	perc = (upper + lower) / 2
	curve = bezier_curve(p1, p2, p3, p4, perc)
	xx = curve[X]
	
	for (var i = 0; i < 10 && (abs(t - xx) >= 0.001); i++)
	{
		if (t > xx)
			lower = perc
		else
			upper = perc
		
		perc = (upper + lower) / 2
		curve = bezier_curve(p1, p2, p3, p4, perc)
		xxprev = xx
		xx = curve[X]
	}
	
	curve = bezier_curve(p1, p2, p3, p4, perc)
	
	return curve[Y]
}