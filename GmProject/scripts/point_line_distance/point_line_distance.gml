/// @arg linex1
/// @arg liney1
/// @arg linex2
/// @arg liney2
/// @arg pointx
/// @arg pointy

function point_line_distance(x1, y1, x2, y2, x3, y3)
{
	var x0, y0, cx, cy, t;
	cx = x2 - x1
	cy = y2 - y1
	
	if (cx = 0 && cy = 0)
	{
		x0 = x1
		y0 = y1
	}
	else
	{
		t = clamp(((x3 - x1) * cx + (y3 - y1) * cy) / (cx * cx + cy * cy), 0, 1)
		x0 = x1 + t * cx
		y0 = y1 + t * cy
	}
	
	return point_distance(x3, y3, x0, y0)
}
