/// @arg point1
/// @arg point2
/// @arg point3
/// @arg point4
/// @arg progress

function ease_bezier_curve(p1, p2, p3, p4, t)
{
	if (t = 0 || t = 1)
		return t
	
	var lower, upper, perc, xx, x1, x2, x3;
	lower = 0
	upper = 1
	
	// Search only X without allocating intermediate points
	for (var i = 0; i <= 10; i++)
	{
		perc = (upper + lower) / 2
		x1 = lerp(p1[X], p2[X], perc)
		x2 = lerp(p2[X], p3[X], perc)
		x3 = lerp(p3[X], p4[X], perc)
		xx = lerp(lerp(x1, x2, perc), lerp(x2, x3, perc), perc)

		if (!(abs(t - xx) >= 0.001))
			break

		if (t > xx)
			lower = perc
		else
			upper = perc
	}
	
	var y1, y2, y3;
	y1 = lerp(p1[Y], p2[Y], perc)
	y2 = lerp(p2[Y], p3[Y], perc)
	y3 = lerp(p3[Y], p4[Y], perc)
	
	return lerp(lerp(y1, y2, perc), lerp(y2, y3, perc), perc)
}
